# LAB01 — DevOps Info Service (Python)

## 1. Framework Selection
I chose **Flask** because:
- lightweight and simple for a small service
- fast to implement
- minimal dependencies

### Comparison Table

| Framework | Pros | Cons |
|----------|------|------|
| Flask | Simple, lightweight, beginner-friendly | Less built-in features |
| FastAPI | Modern, fast, auto docs | More concepts (Pydantic/async) |
| Django | Full-featured, ORM included | Too heavy for this small service |

---

## 2. Best Practices Applied

### Clean Code Organization
- functions separated by responsibility (`get_system_info`, `get_runtime_info`, etc.)
- clear naming + docstrings
- grouped imports

### Error Handling
- custom handlers for `404` and `500` returning JSON errors

### Logging
- configured with timestamps and log level
- logs every request to `/` and `/health`

### Dependencies
- pinned exact version in `requirements.txt`

---

## 3. API Documentation

### Test main endpoint
```bash
curl http://127.0.0.1:5000/
```
### Pretty print:
```bash
curl -s http://127.0.0.1:5000/ | jq
```
### Test health endpoint
```bash
curl http://127.0.0.1:5000/health
```
## 4. Testing Evidence
Screenshots are saved in:

`app_python/docs/screenshots/`

## 5. Challenges & Solutions

* **Challenge:** extracting correct client IP behind proxies
* **Solution:** used `X-Forwarded-For` header fallback to `request.remote_addr`

## 6. GitHub Community
Starring repositories helps bookmark useful tools and increases visibility/support for open source maintainers.

Following developers (professor, TAs, classmates) helps discover new work, learn collaboration habits, and stay connected for future projects.
