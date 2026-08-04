from __future__ import annotations

import os
from dataclasses import dataclass


class ConfigurationError(RuntimeError):
    pass


@dataclass(frozen=True)
class Settings:
    app_name: str
    app_env: str
    app_version: str
    database_url: str
    redis_url: str
    log_level: str


def load_settings() -> Settings:
    required = {
        "DATABASE_URL": os.getenv("DATABASE_URL"),
        "REDIS_URL": os.getenv("REDIS_URL"),
    }
    missing = [name for name, value in required.items() if not value]
    if missing:
        raise ConfigurationError(
            "Required environment variable(s) missing: " + ", ".join(missing)
        )

    return Settings(
        app_name=os.getenv("APP_NAME", "northstar-checkout"),
        app_env=os.getenv("APP_ENV", "development"),
        app_version=os.getenv("APP_VERSION", "0.3.0"),
        database_url=required["DATABASE_URL"] or "",
        redis_url=required["REDIS_URL"] or "",
        log_level=os.getenv("LOG_LEVEL", "INFO").upper(),
    )
