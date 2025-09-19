# -------- Stage 1 --------

FROM golang:1.24-alpine AS builder

WORKDIR /app

# allowing C code from sqlite to be compiled into backend
RUN apk add --no-cache gcc musl-dev
ENV CGO_ENABLED=1

# caching go env
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -v -ldflags="-s -w" -trimpath -o server .

# -------- Stage 2 --------

FROM alpine:3.22

WORKDIR /app

COPY --from=builder /app/server .

EXPOSE 8080

CMD ["./server"]