from django.shortcuts import render

# Create your views here.
def index(request):
    return render(request, 'frontend/index.html')

def leer_checadas(host, port=4370, timeout=5, password=0):
    from zk import ZK  # import perezoso
    zk = ZK(host, port=port, timeout=timeout, password=password, force_udp=False, ommit_ping=False)
    conn = None
    try:
        conn = zk.connect()
        conn.disable_device()
        return conn.get_attendance() or []
    finally:
        try:
            if conn:
                conn.enable_device()
                conn.disconnect()
        except Exception:
            pass


def zk_sync_html(request):
    host = "192.168.2.185"
    error, rows = None, []
    try:
        att = leer_checadas(host)

        from django.utils import timezone
        def to_local(dt):
            if timezone.is_naive(dt):
                dt = timezone.make_aware(dt, timezone.get_default_timezone())
            return timezone.localtime(dt)

        rows = [{
            "user_id": getattr(a, "user_id", None),
            "timestamp": to_local(getattr(a, "timestamp", None)),
        } for a in att]

        rows.sort(key=lambda r: r["timestamp"], reverse=True)  # más reciente primero
    except Exception as e:
        error = str(e)

    return render(request, "frontend/zk_sync.html", {
        "host": host,
        "count": len(rows),
        "rows": rows[:500],   # muestra hasta 500
        "error": error,
    })
