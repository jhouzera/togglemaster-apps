# ---- Stage 1: Builder ----
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copia manifests e código juntos para que go mod tidy possa gerar go.sum
COPY go.mod *.go ./

# go mod tidy baixa as dependências e gera go.sum de forma consistente
RUN go mod tidy

# Compila o binário estático (sem CGO) para ser copiado para uma imagem mínima
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /auth-service .

# ---- Stage 2: Runtime ----
FROM alpine:3.19

# ca-certificates é necessário para conexões TLS (ex: PostgreSQL com SSL)
RUN apk add --no-cache ca-certificates

COPY --from=builder /auth-service /auth-service

EXPOSE 8001

ENTRYPOINT ["/auth-service"]
