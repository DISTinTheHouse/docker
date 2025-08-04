# Imagen base ligera
FROM python:3.11-slim

# Directorio de trabajo
WORKDIR /app

# (Opcional) Dependencias del sistema si usas PostgreSQL o paquetes con C extensions
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpq-dev \
#     && rm -rf /var/lib/apt/lists/*

# Copiar solo requirements primero
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copiar el resto del proyecto
COPY . .

# Exponer puerto estándar de Django (Render lo requiere)
EXPOSE 8000

# (Opcional en prod) Collect static files
# RUN python backend/manage.py collectstatic --noinput

# Comando de arranque
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
