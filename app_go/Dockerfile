# Stage 1: builder
FROM golang:1.22 AS builder

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o app .

# Stage 2: runtime
FROM alpine:3.20

WORKDIR /app
COPY --from=builder /src/app .


EXPOSE 8080
CMD ["./app"]