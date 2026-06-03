# CK-01 — Vulnerable base image.
# FROM python:3.9-slim
# CK-01 REMEDIATED — upgraded to python:3.12-slim
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# CK-02 / IV-05 — runs as root. No HEALTHCHECK.
# CK-02 / IV-05 REMEDIATED — non-root user
RUN groupadd -r app && useradd -r -g app app \
    && chown -R app:app /app
USER app

# HEALTHCHECK added — hits the real /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1


EXPOSE 5000

CMD ["python", "app.py"]
