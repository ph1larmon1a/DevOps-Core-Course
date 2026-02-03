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

## Docker

### Build locally
docker build -t python-app .

### Run container
docker run --rm -p 8000:8000 python-app

### Pull from Docker Hub
docker pull s1mphonia/devops-core-course-python-app:latest
docker run --rm -p 8000:8000 s1mphonia/devops-core-course-python-app
