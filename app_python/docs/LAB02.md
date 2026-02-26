# Lab 02 — Docker Containerization

## 1. Docker Best Practices Applied

### Non-root user
I created a dedicated user (`appuser`) and switched to it using `USER appuser`.
This improves security by preventing root-level access inside the container.

### Layer caching (dependency-first copy)
I copied `requirements.txt` before copying the full application source:
- Faster rebuilds when code changes
- Dependencies only reinstall when requirements change

### Small base image
I used `python:3.13-slim` to reduce image size while keeping compatibility.

### .dockerignore
I excluded dev-only files like venv, git metadata, caches, tests, and docs.
This reduces build context size and speeds up builds.

---

## 2. Image Information & Decisions

### Base image choice
**python:3.13-slim**
- Small footprint
- Official and maintained
- Good for production containers

### Image size
Final image size: **148MB**

### Layer structure
1. Base image
2. Create non-root user
3. Copy requirements + install dependencies
4. Copy app source
5. Run app as non-root user

---

## 3. Build & Run Process

### Build output
```bash
$ docker build -t python-app app_python/

[+] Building 3.8s (15/15) FINISHED                                                                                                                  docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                                0.0s
 => => transferring dockerfile: 354B                                                                                                                                0.0s
 => resolve image config for docker-image://docker.io/docker/dockerfile:1                                                                                           2.4s
 => [auth] docker/dockerfile:pull token for registry-1.docker.io                                                                                                    0.0s
 => CACHED docker-image://docker.io/docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6                                     0.0s
 => [internal] load metadata for docker.io/library/python:3.13-slim                                                                                                 1.2s
 => [auth] library/python:pull token for registry-1.docker.io                                                                                                       0.0s
 => [internal] load .dockerignore                                                                                                                                   0.0s
 => => transferring context: 166B                                                                                                                                   0.0s
 => [1/6] FROM docker.io/library/python:3.13-slim@sha256:2b9c9803c6a287cafa0a8c917211dddd23dcd2016f049690ee5219f5d3f1636e                                           0.0s
 => [internal] load build context                                                                                                                                   0.0s
 => => transferring context: 125B                                                                                                                                   0.0s
 => CACHED [2/6] RUN useradd --create-home --shell /bin/bash appuser                                                                                                0.0s
 => CACHED [3/6] WORKDIR /app                                                                                                                                       0.0s
 => CACHED [4/6] COPY requirements.txt .                                                                                                                            0.0s
 => CACHED [5/6] RUN pip install --no-cache-dir -r requirements.txt                                                                                                 0.0s
 => CACHED [6/6] COPY . .                                                                                                                                           0.0s
 => exporting to image                                                                                                                                              0.0s
 => => exporting layers                                                                                                                                             0.0s
 => => writing image sha256:562eddae025a7af9be7c6f1c0d7e889deedbbb4d30a9b4b8f99c0ff60ee8d4f4                                                                        0.0s
 => => naming to docker.io/library/python-app                                                                                                                       0.0s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/zskjg8fybjffvn8sygiy67fs9
```
### Run container
```bash
$ docker run --rm -p 8000:8000 python-app

 * Serving Flask app 'app'
 * Debug mode: off
2026-02-03 16:46:03,334 - devops-info-service - INFO - Starting DevOps Info Service on 0.0.0.0:8000 (debug=False)
2026-02-03 16:46:03,340 - werkzeug - INFO - WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://172.17.0.2:8000
2026-02-03 16:46:03,340 - werkzeug - INFO - Press CTRL+C to quit

```
### Test endpoints
```bash
$ curl http://localhost:8000/health
{"status":"healthy","timestamp":"2026-02-03T16:47:14.761583+00:00","uptime_seconds":20}
```
### Docker Hub
Repository URL:
https://hub.docker.com/r/s1mphonia/devops-core-course-python-app
## 4. Technical Analysis
### Why the Dockerfile works
* Dependencies installed once (cached)
* Code copied after dependencies
* Runs safely as non-root
### What if layer order changed?
If I copied the full source before installing dependencies, Docker would reinstall packages every time I changed code → slower builds.
### Security considerations
* Non-root user reduces risk of container breakout damage
* Slim image reduces attack surface
### How .dockerignore helps
* Smaller build context
* Faster builds
* Prevents secrets/dev junk from being baked into the image
## 5. Challenges & Solutions
### Example: port mismatch
**Issue:** app didn’t respond on expected port \
**Fix:** updated docker run -p mapping and confirmed correct port.

What I learned:

* Docker caching depends heavily on layer order
* Non-root containers are essential for production safety

