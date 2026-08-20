from __future__ import annotations

import logging
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import JSONResponse
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from .config import ConfigurationError, Settings, load_settings
from .dependencies import DependencyClients
from .logging_config import configure_logging
from .metrics import (
    CHECKOUT_ATTEMPTS_TOTAL,
    CHECKOUT_QUALITY_TOTAL,
    DEPENDENCY_UP,
    HTTP_REQUEST_DURATION_SECONDS,
    HTTP_REQUESTS_TOTAL,
)

logger = logging.getLogger("northstar.checkout")
settings: Settings | None = None
clients: DependencyClients | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global settings, clients
    try:
        settings = load_settings()
        configure_logging(settings.log_level)
        clients = DependencyClients(
            database_url=settings.database_url,
            redis_url=settings.redis_url,
        )
        logger.info(
            "Starting Checkout API version=%s environment=%s",
            settings.app_version,
            settings.app_env,
        )
        logger.info("Checkout API startup completed")
        yield
    except ConfigurationError:
        logger.exception("Checkout API startup failed because configuration is invalid")
        raise
    finally:
        logger.info("Checkout API shutting down")


app = FastAPI(
    title="Northstar Checkout Service",
    version="0.3.0",
    lifespan=lifespan,
)


@app.middleware("http")
async def collect_http_metrics(request: Request, call_next):
    start = time.perf_counter()
    status_code = 500
    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    finally:
        duration = time.perf_counter() - start
        path = request.url.path
        HTTP_REQUESTS_TOTAL.labels(
            method=request.method,
            path=path,
            status=str(status_code),
        ).inc()
        HTTP_REQUEST_DURATION_SECONDS.labels(
            method=request.method,
            path=path,
        ).observe(duration)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "healthy"}


@app.get("/ready")
async def readiness():
    if clients is None:
        return JSONResponse(status_code=503, content={"status": "not-ready"})

    database_ok = clients.check_database()
    redis_ok = clients.check_redis()

    DEPENDENCY_UP.labels(dependency="postgres").set(1 if database_ok else 0)
    DEPENDENCY_UP.labels(dependency="redis").set(1 if redis_ok else 0)

    if not database_ok or not redis_ok:
        return JSONResponse(
            status_code=503,
            content={
                "status": "not-ready",
                "postgres": database_ok,
                "redis": redis_ok,
            },
        )

    return {
        "status": "ready",
        "postgres": True,
        "redis": True,
    }


@app.get("/metrics")
async def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.post("/api/v1/checkout/{customer_id}")
async def checkout(customer_id: str) -> dict[str, object]:
    if clients is None:
        raise HTTPException(status_code=503, detail="Dependencies not initialised")

    if settings is not None and settings.inject_latency_ms > 0:
        time.sleep(settings.inject_latency_ms / 1000)

    if settings is not None and settings.inject_checkout_failure:
        CHECKOUT_ATTEMPTS_TOTAL.labels(result="failed").inc()
        raise HTTPException(
            status_code=503,
            detail="Injected Checkout failure",
        )

    try:
        event_id = clients.create_checkout_event(customer_id)
        clients.cache_checkout_event(event_id, customer_id)
        CHECKOUT_ATTEMPTS_TOTAL.labels(result="accepted").inc()

        quality_invalid = (
            settings is not None
            and settings.inject_quality_failure
        )

        if quality_invalid:
            CHECKOUT_QUALITY_TOTAL.labels(outcome="invalid").inc()
        else:
            CHECKOUT_QUALITY_TOTAL.labels(outcome="valid").inc()
        logger.info(
            "Checkout accepted customer_id=%s event_id=%s",
            customer_id,
            event_id,
        )
        return {
            "status": "accepted",
            "event_id": event_id,
            "customer_id": (
                "CORRUPTED-CUSTOMER"
                if quality_invalid
                else customer_id
            ),
        }
    except Exception as exc:
        CHECKOUT_ATTEMPTS_TOTAL.labels(result="failed").inc()
        logger.exception("Checkout failed customer_id=%s", customer_id)
        raise HTTPException(status_code=503, detail="Checkout unavailable") from exc


@app.get("/api/v1/checkout/events/{event_id}")
async def get_event(event_id: int) -> dict[str, object]:
    if clients is None:
        raise HTTPException(status_code=503, detail="Dependencies not initialised")

    cached = clients.get_cached_checkout_event(event_id)
    if cached is None:
        raise HTTPException(status_code=404, detail="Checkout event not found")

    return {
        "event_id": event_id,
        **cached,
        "source": "redis",
    }
