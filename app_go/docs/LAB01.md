# LAB01 — DevOps Info Service (Go)

## Build & Run
```bash
go build -o devops-info-service main.go
./devops-info-service
```
## Test
```bash
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/health
```
## Binary size comparison
After building, compare:
```bash
ls -lh devops-info-service
```
Screenshots go in:

`app_go/docs/screenshots/`