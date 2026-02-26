# LAB02 — Multi-Stage Docker Build (Go)

## Overview
In this lab, I containerized my compiled Go application using a **multi-stage Docker build**.  
The goal was to keep the final image small, secure, and production-ready by separating:

- **Stage 1 (Builder):** compile the Go binary
- **Stage 2 (Runtime):** run only the compiled binary in a minimal environment

---

## 1. Multi-Stage Build Strategy

### Why Multi-Stage?
Go apps require a compiler to build, but the compiler is **not needed at runtime**.

Multi-stage builds solve this by:
- Using a full Go SDK image only for building
- Copying only the final binary into a lightweight runtime image

This results in:
- Smaller final image size
- Fewer dependencies included
- Reduced attack surface

---

## 2. Dockerfile Used

File: `app_go/Dockerfile`

```dockerfile
# Stage 1: builder
FROM golang:1.22 AS builder

WORKDIR /src
COPY . .
RUN go build -o app .

# Stage 2: runtime
FROM alpine:3.20

WORKDIR /app
COPY --from=builder /src/app .

EXPOSE 8080
CMD ["./app"]
```

## 3. Explanation of Each Stage
### Stage 1 — Builder
**Base image:** `golang:1.22` \
This stage:

* Includes the Go toolchain and build dependencies
* Compiles the source code into a binary using:
```bash
go build -o app .
```
Output:
* A compiled executable named `app`
### Stage 2 — Runtime
**Base image:** `alpine:3.20`
This stage:

* Is very small compared to the builder stage
* Does not contain Go, compilers, or build tools
* Copies only the compiled binary from the builder stage:
```dockerfile
COPY --from=builder /src/app .
```
This is the final image that gets shipped.
## 4. Build & Run Process
### Build the image
```bash
$ docker build -t s1mphonia/app-go:latest app_go/

[+] Building 5.6s (15/15) FINISHED                                                                                                                  docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                                0.0s
 => => transferring dockerfile: 303B                                                                                                                                0.0s
 => [internal] load metadata for docker.io/library/golang:1.22                                                                                                      1.3s
 => [internal] load metadata for docker.io/library/alpine:3.20                                                                                                      1.4s
 => [internal] load .dockerignore                                                                                                                                   0.0s
 => => transferring context: 93B                                                                                                                                    0.0s
 => [builder 1/6] FROM docker.io/library/golang:1.22@sha256:1cf6c45ba39db9fd6db16922041d074a63c935556a05c5ccb62d181034df7f02                                        0.0s
 => [internal] load build context                                                                                                                                   0.0s
 => => transferring context: 391B                                                                                                                                   0.0s
 => [stage-1 1/3] FROM docker.io/library/alpine:3.20@sha256:a4f4213abb84c497377b8544c81b3564f313746700372ec4fe84653e4fb03805                                        0.0s
 => CACHED [builder 2/6] WORKDIR /src                                                                                                                               0.0s
 => CACHED [builder 3/6] COPY go.mod ./                                                                                                                             0.0s
 => CACHED [builder 4/6] RUN go mod download                                                                                                                        0.0s
 => [builder 5/6] COPY . .                                                                                                                                          0.0s
 => [builder 6/6] RUN CGO_ENABLED=0 GOOS=linux go build -o app .                                                                                                    4.1s
 => CACHED [stage-1 2/3] WORKDIR /app                                                                                                                               0.0s
 => [stage-1 3/3] COPY --from=builder /src/app .                                                                                                                    0.0s
 => exporting to image                                                                                                                                              0.0s
 => => exporting layers                                                                                                                                             0.0s
 => => writing image sha256:2554aeaad0e03931e31aa4f135a48c2425c059551ef59ecb1f9cc1947f2c1704                                                                        0.0s
 => => naming to docker.io/library/app-go                                                                                                                           0.0s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/d8yvtnkuft1iz4zqnpq5r861i
```

### Run the container
```bash
$ docker run --rm -p 8080:8080 app-go 
nothing here xD
```

### Test the endpoint
```bash
$ curl http://localhost:8080/health
{"status":"healthy","timestamp":"2026-02-03T17:15:30.665305925Z","uptime_seconds":4}
```
## 5. Image Size Comparison
### To compare image sizes:
```bash
$ docker images
Example output:
REPOSITORY           TAG       IMAGE ID       SIZE
app-go                                    latest               2554aeaad0e0   2 minutes ago    15.8MB
python-app                                latest               562eddae025a   43 minutes ago   148MB
```
### Size analysis
* The builder stage uses a large Go SDK image (~900MB)
* The final runtime image is small (~10–20MB typical)
* The final image contains only:
  * the Go binary
  * minimal Alpine runtime dependencies
This is a major improvement over shipping the full Go SDK.
## 6. Why Multi-Stage Builds Matter
### Benefits
* Smaller images
* Faster pulls/deployments
* Less storage usage
* Reduced attack surface
* Cleaner runtime environment
### What happens without multi-stage?
If I used the Go SDK image as the runtime image:
* The final image would be huge
* It would include build tools unnecessarily
* More packages = more vulnerabilities
## 7. Security Considerations
### Reduced attack surface
A smaller image means:
* fewer libraries installed
* fewer tools available to an attacker
* fewer vulnerabilities overall
### Minimal runtime environment
By using Alpine and only copying the binary:
* the container has fewer moving parts
* runtime is more predictable
## 8. Challenges & Solutions
### Challenge 1: `exec ./app: no such file or directory`
**Problem:**  
When I started the container, Docker returned:

```bash
exec ./app: no such file or directory
```
**Cause:** 
This happened because the Go binary was not built in a way that matched the runtime environment. \
Common reasons include:
* The binary was compiled for the wrong OS/architecture
* The binary required dynamic linking (CGO) that wasn’t available in the minimal runtime image

**Solution:**
I fixed this by compiling a Linux static binary in the builder stage:
```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -o app .
```
This ensured the executable could run correctly inside the Alpine runtime container.

## What I learned
* Multi-stage builds are the standard way to ship compiled apps
* The final runtime image should contain only what is needed to run
* Image size impacts deployment speed and security