## Project title

**go-README** — A production-grade Go project starter. Uses the standard `cmd/` / `internal/` / `pkg/` layout with `net/http` (or Chi/Gin), Go modules, and a full CI pipeline.

## Motivation

Go's standard tooling produces static binaries, but spinning up a well-structured project with testing, linting, and proper package boundaries still takes effort. This README codifies a single, repeatable layout so you can ship fast without reinventing the wiring.

## Build status

[![Go](https://github.com/yourorg/yourrepo/actions/workflows/go.yml/badge.svg)](https://github.com/yourorg/yourrepo/actions/workflows/go.yml)

```yaml
# .github/workflows/go.yml
name: Go
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.23"
      - run: go build ./cmd/...
      - run: go test -v -race -count=1 ./...
      - run: make lint
```

## Code style

- **Formatter:** `gofmt` (or `go fmt ./...`) — non-negotiable.
- **Linter:** [`golangci-lint`](https://golangci-lint.run) with `gofumpt`, `govet`, `errcheck`, `ineffassign`, `staticcheck`.
- **Conventions:** `error` as last return value, no `panic` in libraries, `context.Context` as first argument, Unexported package-level globals.

```makefile
# Makefile
lint:
	golangci-lint run ./... --timeout 5m
fmt:
	gofmt -w -s .
```

## Screenshots

<!-- TODO: Add terminal recording or dashboard screenshot -->

## Tech/framework used

- **Language:** Go 1.23+
- **Router:** [`net/http`](https://pkg.go.dev/net/http) (stdlib) or [`chi`](https://go-chi.io) / [`gin`](https://gin-gonic.com)
  - _chi_ — lightweight, idiomatic stdlib-compatible router.
  - _Gin_ — high-performance with middleware chaining.
- **Modules:** [`go mod`](https://go.dev/ref/mod) for dependency management.
- **DB:** [`pgx`](https://github.com/jackc/pgx) / [`sqlx`](https://github.com/jmoiron/sqlx) (not included — add as needed).

## Features

- Standard `cmd/`/`internal/`/`pkg/` structure (per [golang-standards/project-layout](https://github.com/golang-standards/project-layout)).
- Graceful shutdown with `os.Signal` handling.
- Structured logging via `log/slog` (stdlib, Go 1.21+).
- Middleware chaining (request ID, logging, recovery, CORS).
- Single-binary deployment — no runtime deps.

## Code Example

```go
// cmd/api/main.go
package main

import (
 "context"
 "log/slog"
 "net/http"
 "os"
 "os/signal"
 "time"

 "github.com/go-chi/chi/v5"
 "github.com/go-chi/chi/v5/middleware"
)

func main() {
 r := chi.NewRouter()
 r.Use(middleware.Logger)
 r.Use(middleware.Recoverer)
 r.Use(middleware.RequestID)

 r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json")
  w.Write([]byte(`{"status":"ok"}`))
 })

 srv := &http.Server{Addr: ":8080", Handler: r}

 go func() {
  slog.Info("listening", "addr", srv.Addr)
  if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
   slog.Error("server error", "err", err)
   os.Exit(1)
  }
 }()

 quit := make(chan os.Signal, 1)
 signal.Notify(quit, os.Interrupt)
 <-quit

 ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
 defer cancel()
 if err := srv.Shutdown(ctx); err != nil {
  slog.Error("shutdown error", "err", err)
  os.Exit(1)
 }
}
```

## Installation

```bash
go version               # verify Go 1.23+
go mod init github.com/yourorg/yourrepo
go get github.com/go-chi/chi/v5   # or github.com/gin-gonic/gin
go mod download
go build ./cmd/api
```

## API Reference

- Package docs: `go doc ./...`
- Online godoc: [pkg.go.dev/github.com/yourorg/yourrepo](https://pkg.go.dev/github.com/yourorg/yourrepo)
- Handler signatures follow net/http conventions: `func(w http.ResponseWriter, r *http.Request)`.

## Tests

```bash
go test -v -race -count=1 -cover ./...

# With coverage report
go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out
```

Example test:

```go
// internal/handler/health_test.go
package handler

import (
 "net/http"
 "net/http/httptest"
 "testing"
)

func TestHealthHandler(t *testing.T) {
 req := httptest.NewRequest(http.MethodGet, "/health", nil)
 rec := httptest.NewRecorder()

 HealthHandler(rec, req)

 if rec.Code != http.StatusOK {
  t.Fatalf("expected 200, got %d", rec.Code)
 }
}
```

## How to use

1. Clone this repo or copy the layout.
2. Replace `github.com/yourorg/yourrepo` in `go.mod`.
3. Add your handlers under `internal/handler/`.
4. Wire routes in `cmd/api/main.go`.
5. Run `go build ./cmd/api && ./api`.
6. Visit `http://localhost:8080/health`.

## Contribute

PRs are welcome. Before submitting:

- Run `make fmt && make lint && make test`.
- Open an issue for design discussions first.
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

## Credits

This guide is based on the [Kickass README](https://github.com/akashnimare/kickass-readme) template by Akash Nimare. Project structure follows the [golang-standards/project-layout](https://github.com/golang-standards/project-layout) conventions.

## License

MIT © [Your Name](https://github.com/yourname)
