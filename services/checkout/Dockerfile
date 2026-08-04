# syntax=docker/dockerfile:1

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1     PIP_NO_CACHE_DIR=1     APP_HOME=/app

WORKDIR ${APP_HOME}

RUN groupadd --system --gid 10001 northstar     && useradd --system --uid 10001 --gid northstar --home-dir ${APP_HOME} northstar

COPY requirements.txt .
RUN pip install --no-cache-dir --requirement requirements.txt

COPY --chown=northstar:northstar app ./app

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5   CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
