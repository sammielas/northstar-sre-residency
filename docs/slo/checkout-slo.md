# Checkout Service Reliability Objectives

## Service

Checkout API

---

## SLI 1 – Availability

Measurement

Successful scrapes of the Checkout service.

Metric

northstar_checkout_dependency_up

Objective

99.9%

---

## SLI 2 – Request Latency

Measurement

95th percentile latency.

Metric

northstar_checkout_http_request_duration_seconds_bucket

Objective

P95 < 250ms

---

## SLI 3 – Error Rate

Measurement

Percentage of HTTP 5xx responses.

Metric

northstar_checkout_http_requests_total

Objective

<1%

---

## SLI 4 – Dependency Health

Measurement

Redis + PostgreSQL reachable.

Metric

northstar_checkout_dependency_up

Objective

100%