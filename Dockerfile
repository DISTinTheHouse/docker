# Etapa 1: Construcción del frontend con webpack
FROM node:18 AS frontend-builder

WORKDIR /frontend

# Copiar package.json y lock primero para aprovechar cache
COPY frontend/package*.json ./

RUN npm install

# Copiar el resto del frontend
COPY frontend/ ./

# Ejecutar webpack (compilar React → main.js)
RUN npx webpack --config webpack.config.js

# Etapa 2: Backend con Python + Django
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar dependencias de Python
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copiar todo el código del proyecto
COPY . .

# Copiar los assets ya compilados del frontend
COPY --from=frontend-builder /frontend/static/frontend /app/frontend/static/frontend

# Recolectar archivos estáticos de Django
#RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Comando de arranque
CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]
