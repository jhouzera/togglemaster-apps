# ---- Stage 1: Builder ----
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ---- Stage 2: Runtime ----
FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY app.py .

ENV PATH=/root/.local/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

EXPOSE 8005

# --workers 1 garante um único processo worker, evitando múltiplos pollers na fila SQS
CMD gunicorn --bind 0.0.0.0:${PORT:-8005} --workers 1 --threads 2 app:app
