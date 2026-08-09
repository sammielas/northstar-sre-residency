FROM python:3.12-slim

WORKDIR /app

RUN useradd \
    --uid 10001 \
    --create-home \
    --shell /usr/sbin/nologin \
    northstar

COPY app.py /app/app.py

RUN chown -R northstar:northstar /app

USER 10001:10001

EXPOSE 8080

CMD ["python", "/app/app.py"]