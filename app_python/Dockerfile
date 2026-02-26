# syntax=docker/dockerfile:1

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
