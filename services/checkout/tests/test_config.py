import pytest

from app.config import ConfigurationError, load_settings


def test_missing_database_url(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("REDIS_URL", "redis://redis:6379/0")
    with pytest.raises(ConfigurationError, match="DATABASE_URL"):
        load_settings()
