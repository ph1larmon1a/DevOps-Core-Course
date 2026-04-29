# DevOps Info Service (Go)

## Build
```bash
go build -o devops-info-service main.go
```
## Run
```bash
./devops-info-service
```
## Custom port:
```bash
PORT=9090 ./devops-info-service
```
## Endpoints
* `GET /`
* `GET /health`

## Docker

### Build locally
docker build -t go-app .

### Run container
docker run --rm -p 8000:8000 go-app

### Pull from Docker Hub
docker pull s1mphonia/devops-core-course-python-app:latest
docker run --rm -p 8000:8000 s1mphonia/devops-core-course-python-app