# # Imagen base ligera
# FROM python:3.11-slim

# # Directorio de trabajo
# WORKDIR /app

# # (Opcional) Dependencias del sistema si usas PostgreSQL o paquetes con C extensions
# # RUN apt-get update && apt-get install -y \
# #     build-essential \
# #     libpq-dev \
# #     && rm -rf /var/lib/apt/lists/*

# # Copiar solo requirements primero
# COPY requirements.txt .

# # Instalar dependencias de Python
# RUN pip install --upgrade pip && pip install -r requirements.txt

# # Copiar el resto del proyecto
# COPY . .

# # Exponer puerto estándar de Django (Render lo requiere)
# EXPOSE 8000

# # (Opcional en prod) Collect static files
# # RUN python backend/manage.py collectstatic --noinput

# # Comando de arranque
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


# Imagen base con Python
FROM python:3.11-slim

# Variables de entorno (evita mensajes interactivos y buffer)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js y npm (LTS actual)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Crear carpeta de trabajo
WORKDIR /app

# Copiar archivos del proyecto
COPY . .

# Instalar dependencias Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Instalar frontend y compilar React con Webpack
WORKDIR /app/frontend
RUN npm install && npx webpack

# Volver al root del proyecto para correr Django
WORKDIR /app

# Exponer el puerto por defecto (Render usa 8000)
EXPOSE 8000

# Ejecutar Django
CMD ["python", "backend/manage.py", "runserver", "0.0.0.0:8000"]
