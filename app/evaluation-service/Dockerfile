# ---- Stage 1: Builder ----
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod *.go ./

RUN go mod tidy

# Compila o binário estático; evaluation-service usa AWS SDK (HTTPS) e Redis
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /evaluation-service .

# ---- Stage 2: Runtime ----
FROM alpine:3.19

# ca-certificates é necessário para chamadas HTTPS (AWS SQS, Redis TLS)
RUN apk add --no-cache ca-certificates

COPY --from=builder /evaluation-service /evaluation-service

EXPOSE 8004

ENTRYPOINT ["/evaluation-service"]
