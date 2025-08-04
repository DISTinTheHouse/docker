import React, { useEffect, useState } from "react";

const initialForm = { codigo: "", nombre: "", descripcion: "", activo: false };

function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return decodeURIComponent(parts.pop().split(";").shift());
  return null;
}

export default function App() {
  const [form, setForm] = useState(initialForm);
  const [items, setItems] = useState([]);
  const [loadingList, setLoadingList] = useState(false);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState("");

  const csrftoken = getCookie("csrftoken");

  async function fetchAlmacenes() {
    try {
      setLoadingList(true);
      setError("");
      const res = await fetch("/api/almacenes/");
      if (!res.ok) throw new Error(`Error ${res.status}`);
      const data = await res.json();
      setItems(data);
    } catch (e) {
      setError(e.message || "Error cargando almacenes");
    } finally {
      setLoadingList(false);
    }
  }

  useEffect(() => {
    fetchAlmacenes();
  }, []);

  function validate() {
    if (!form.codigo.trim()) return "El código es obligatorio.";
    if (!form.nombre.trim()) return "El nombre es obligatorio.";
    return "";
  }

  async function handleSubmit(e) {
    e.preventDefault();
    const msg = validate();
    if (msg) return setError(msg);

    try {
      setCreating(true);
      setError("");
      const res = await fetch("/api/almacenes/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": csrftoken || ""
        },
        body: JSON.stringify({
          codigo: form.codigo.trim(),
          nombre: form.nombre.trim(),
          descripcion: form.descripcion.trim(),
          activo: !!form.activo
        })
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(`Error ${res.status}: ${txt}`);
      }
      setForm(initialForm);
      fetchAlmacenes();
    } catch (e) {
      setError(e.message || "Error creando almacén");
    } finally {
      setCreating(false);
    }
  }

  return (
    <div className="container py-4">
      <h1 className="mb-4">Almacenes</h1>

      <div className="card shadow-sm mb-4">
        <div className="card-body">
          <h5 className="card-title">Nuevo almacén</h5>
          {error && <div className="alert alert-danger py-2 my-3">{error}</div>}

          <form onSubmit={handleSubmit} className="row g-3">
            <div className="col-md-3">
              <label className="form-label">Código *</label>
              <input
                className="form-control"
                value={form.codigo}
                onChange={(e) => setForm({ ...form, codigo: e.target.value })}
                required
              />
            </div>

            <div className="col-md-5">
              <label className="form-label">Nombre *</label>
              <input
                className="form-control"
                value={form.nombre}
                onChange={(e) => setForm({ ...form, nombre: e.target.value })}
                required
              />
            </div>

            <div className="col-12">
              <label className="form-label">Descripción</label>
              <textarea
                className="form-control"
                rows={3}
                value={form.descripcion}
                onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
              />
            </div>

            <div className="col-12 form-check ms-2">
              <input
                id="activo"
                className="form-check-input"
                type="checkbox"
                checked={form.activo}
                onChange={(e) => setForm({ ...form, activo: e.target.checked })}
              />
              <label className="form-check-label" htmlFor="activo">Activo</label>
            </div>

            <div className="col-12">
              <button className="btn btn-primary" type="submit" disabled={creating}>
                {creating ? "Guardando..." : "Guardar"}
              </button>
              <button
                type="button"
                className="btn btn-outline-secondary ms-2"
                onClick={() => setForm(initialForm)}
                disabled={creating}
              >
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <div className="card shadow-sm">
        <div className="card-body">
          <div className="d-flex justify-content-between align-items-center mb-3">
            <h5 className="card-title mb-0">Listado</h5>
            <button
              className="btn btn-sm btn-outline-primary"
              onClick={fetchAlmacenes}
              disabled={loadingList}
            >
              {loadingList ? "Actualizando..." : "Refrescar"}
            </button>
          </div>

          {loadingList ? (
            <div className="text-muted">Cargando…</div>
          ) : items.length === 0 ? (
            <div className="text-muted">Sin registros.</div>
          ) : (
            <div className="table-responsive">
              <table className="table table-sm table-striped align-middle">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Descripción</th>
                    <th>Activo</th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((it) => (
                    <tr key={it.id}>
                      <td>{it.id}</td>
                      <td className="fw-medium">{it.codigo}</td>
                      <td>{it.nombre}</td>
                      <td className="text-truncate" style={{ maxWidth: 360 }}>
                        {it.descripcion}
                      </td>
                      <td>
                        {it.activo ? (
                          <span className="badge text-bg-success">Sí</span>
                        ) : (
                          <span className="badge text-bg-secondary">No</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
