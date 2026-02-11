# DevOps Info Service (Python)

## Overview
A simple DevOps info service that exposes system/runtime details and a health endpoint.

## Prerequisites
- Python 3.11+
- pip

## Installation
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Testing 

### How to run tests locally:
```bash
pip install -r app_python/requirements.txt
pip install -r app_python/requirements-dev.txt
pytest -v
```

## Docker

### Build locally
```bash
docker build -t python-app .
```

### Run container
```bash
docker run --rm -p 8000:8000 python-app
```

### Pull from Docker Hub
```bash
docker pull s1mphonia/devops-core-course-python-app:latest
docker run --rm -p 8000:8000 s1mphonia/devops-core-course-python-app
```
