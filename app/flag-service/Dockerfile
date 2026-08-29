# ---- Stage 1: Builder ----
# Instala as dependências em um diretório isolado (--user)
# para que apenas os pacotes necessários sejam copiados para o runtime
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ---- Stage 2: Runtime ----
FROM python:3.11-slim

WORKDIR /app

# Copia os pacotes instalados do stage builder
COPY --from=builder /root/.local /root/.local

# Copia apenas o código da aplicação
COPY app.py .

ENV PATH=/root/.local/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

EXPOSE 8002

# Usa shell form para expandir a variável $PORT em runtime
CMD gunicorn --bind 0.0.0.0:${PORT:-8002} --workers 2 app:app
