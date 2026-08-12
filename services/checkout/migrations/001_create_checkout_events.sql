CREATE TABLE IF NOT EXISTS checkout_events (
    id BIGSERIAL PRIMARY KEY,
    customer_id TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
