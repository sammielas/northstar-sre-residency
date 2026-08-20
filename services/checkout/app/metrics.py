from prometheus_client import Counter, Gauge, Histogram

HTTP_REQUESTS_TOTAL = Counter(
    "northstar_checkout_http_requests_total",
    "Total HTTP requests handled by Checkout",
    ["method", "path", "status"],
)

HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "northstar_checkout_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "path"],
)

CHECKOUT_ATTEMPTS_TOTAL = Counter(
    "northstar_checkout_attempts_total",
    "Total checkout attempts",
    ["result"],
)

CHECKOUT_QUALITY_TOTAL = Counter(
    "northstar_checkout_quality_total",
    "Quality outcome of completed checkout transactions",
    ["outcome"],
)

DEPENDENCY_UP = Gauge(
    "northstar_checkout_dependency_up",
    "Dependency availability, where 1 is available and 0 is unavailable",
    ["dependency"],
)
