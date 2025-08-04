# Imagen base ligera de Python
FROM python:3.11-slim

# Evita archivos .pyc y mantiene stdout limpio
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema (incluye Node.js y npm)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar solo requirements.txt para aprovechar el cache de Docker
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copiar todo el proyecto
COPY . .

# --- Compilar React con Webpack ---
WORKDIR /app/frontend

# Instalar dependencias del frontend
RUN npm install

# Compilar React (esto genera static/frontend/main.js)
RUN npx webpack

# --- Volver al root del proyecto para correr Django ---
WORKDIR /app

# Exponer puerto (Render requiere 8000)
EXPOSE 8000

# Comando de arranque para Django (desactiva collectstatic por ahora)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
