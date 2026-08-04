from __future__ import annotations

from dataclasses import dataclass

import psycopg
import redis


@dataclass
class DependencyClients:
    database_url: str
    redis_url: str

    def check_database(self) -> bool:
        try:
            with psycopg.connect(self.database_url, connect_timeout=2) as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1")
                    return cur.fetchone() == (1,)
        except Exception:
            return False

    def check_redis(self) -> bool:
        try:
            client = redis.Redis.from_url(
                self.redis_url,
                socket_connect_timeout=2,
                socket_timeout=2,
                decode_responses=True,
            )
            return bool(client.ping())
        except Exception:
            return False

    def create_checkout_event(self, customer_id: str) -> int:
        with psycopg.connect(self.database_url, connect_timeout=3) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    '''
                    INSERT INTO checkout_events (customer_id, status)
                    VALUES (%s, %s)
                    RETURNING id
                    ''',
                    (customer_id, "accepted"),
                )
                event_id = cur.fetchone()[0]
                conn.commit()
                return int(event_id)

    def cache_checkout_event(self, event_id: int, customer_id: str) -> None:
        client = redis.Redis.from_url(
            self.redis_url,
            socket_connect_timeout=2,
            socket_timeout=2,
            decode_responses=True,
        )
        client.hset(
            f"checkout:{event_id}",
            mapping={
                "customer_id": customer_id,
                "status": "accepted",
            },
        )
        client.expire(f"checkout:{event_id}", 300)

    def get_cached_checkout_event(self, event_id: int) -> dict[str, str] | None:
        client = redis.Redis.from_url(
            self.redis_url,
            socket_connect_timeout=2,
            socket_timeout=2,
            decode_responses=True,
        )
        data = client.hgetall(f"checkout:{event_id}")
        return data or None
