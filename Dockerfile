# Usar imagen oficial de Python
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \

    && rm -rf /var/lib/apt/lists/*

# Copiar archivos
COPY . .

# Instalar dependencias de Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Recoger estáticos (si usas collectstatic en prod)
RUN python backend/manage.py collectstatic --noinput

# Exponer el puerto (Render expone 8000 por defecto)
EXPOSE 8000

# Comando de inicio
CMD ["python", "backend/manage.py", "runserver", "0.0.0.0:8000"]
