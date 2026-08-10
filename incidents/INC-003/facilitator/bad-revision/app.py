from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import time, threading

REQUESTS = {}
DURATIONS = []
LOCK = threading.Lock()
BUCKETS = [0.005,0.01,0.025,0.05,0.1,0.25,0.5,1.0,2.5,5.0]

def observe(status, duration):
    with LOCK:
        REQUESTS[status] = REQUESTS.get(status,0)+1
        DURATIONS.append(duration)

class H(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f'level=info method={self.command} path={self.path} message="{fmt % args}"', flush=True)
    def send_json(self, code, body):
        b=body.encode(); self.send_response(code); self.send_header("Content-Type","application/json"); self.send_header("Content-Length",str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        start=time.time()
        if self.path in ("/health","/ready"):
            code=200; self.send_json(200,'{"status":"healthy","version":"0.4.0-bad"}')
        elif self.path=="/metrics":
            return self.metrics()
        elif self.path.startswith("/checkout"):
            time.sleep(0.70)
            with LOCK: n=sum(REQUESTS.values())+1
            if n%10==0:
                code=500; self.send_json(500,'{"error":"checkout processing regression"}')
            else:
                code=200; self.send_json(200,'{"status":"completed","version":"0.4.0-bad"}')
        else:
            code=404; self.send_json(404,'{"detail":"Not Found"}')
        d=time.time()-start; observe(str(code),d)
        print(f"level=info event=request_complete path={self.path} status_code={code} duration_seconds={d:.6f} version=0.4.0-bad", flush=True)
    def metrics(self):
        with LOCK:
            req=dict(REQUESTS); ds=list(DURATIONS)
        lines=["# HELP northstar_checkout_http_requests_total Total Checkout HTTP requests.","# TYPE northstar_checkout_http_requests_total counter"]
        for status,v in sorted(req.items()):
            lines.append(f'northstar_checkout_http_requests_total{{method="GET",route="/checkout",status_code="{status}"}} {v}')
        lines += ["# HELP northstar_checkout_http_request_duration_seconds Checkout HTTP request duration.","# TYPE northstar_checkout_http_request_duration_seconds histogram"]
        for le in BUCKETS:
            lines.append(f'northstar_checkout_http_request_duration_seconds_bucket{{le="{le}"}} {sum(1 for d in ds if d<=le)}')
        lines += [f'northstar_checkout_http_request_duration_seconds_bucket{{le="+Inf"}} {len(ds)}',
                  f"northstar_checkout_http_request_duration_seconds_count {len(ds)}",
                  f"northstar_checkout_http_request_duration_seconds_sum {sum(ds):.6f}",
                  "# HELP northstar_checkout_dependency_up Dependency health.",
                  "# TYPE northstar_checkout_dependency_up gauge",
                  'northstar_checkout_dependency_up{dependency="postgres"} 1',
                  'northstar_checkout_dependency_up{dependency="redis"} 1']
        b=("\n".join(lines)+"\n").encode()
        self.send_response(200); self.send_header("Content-Type","text/plain; version=0.0.4"); self.send_header("Content-Length",str(len(b))); self.end_headers(); self.wfile.write(b)

print("NorthStar Checkout 0.4.0-bad listening on :8080", flush=True)
ThreadingHTTPServer(("0.0.0.0",8080),H).serve_forever()
