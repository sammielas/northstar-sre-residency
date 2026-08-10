import com.sun.net.httpserver.*;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.lang.management.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

public class CacheLeakApp {
  static final List<byte[]> CACHE = Collections.synchronizedList(new ArrayList<>());
  static volatile boolean leak = false;
  static final AtomicLong requests = new AtomicLong();
  static final List<Double> durations = Collections.synchronizedList(new ArrayList<>());

  static void reply(HttpExchange x, int code, String body, String type) throws IOException {
    byte[] b = body.getBytes(StandardCharsets.UTF_8);
    x.getResponseHeaders().set("Content-Type", type);
    x.sendResponseHeaders(code, b.length);
    try (OutputStream os = x.getResponseBody()) { os.write(b); }
  }

  static String q(HttpExchange x, String key) {
    String raw = x.getRequestURI().getQuery();
    if (raw == null) return null;
    for (String p : raw.split("&")) {
      String[] kv = p.split("=", 2);
      if (kv.length == 2 && kv[0].equals(key)) return kv[1];
    }
    return null;
  }

  public static void main(String[] args) throws Exception {
    HttpServer s = HttpServer.create(new InetSocketAddress(8080), 0);
    s.setExecutor(Executors.newCachedThreadPool());

    s.createContext("/health", x -> reply(x, 200, "{\"status\":\"healthy\"}", "application/json"));
    s.createContext("/ready", x -> reply(x, 200, "{\"status\":\"ready\"}", "application/json"));

    s.createContext("/admin/leak", x -> {
      leak = "true".equalsIgnoreCase(q(x, "enabled"));
      if (!leak) CACHE.clear();
      reply(x, 200, "{\"leak\":" + leak + ",\"cacheEntries\":" + CACHE.size() + "}", "application/json");
    });

    s.createContext("/profile", x -> {
      long start = System.nanoTime();

      try {
        if (leak) {
          CACHE.add(new byte[1024 * 1024]);
          Thread.sleep(Math.min(450, 20 + CACHE.size() * 3L));
        } else {
          Thread.sleep(15);
        }

        reply(x, 200, "{\"profile\":\"ok\",\"cacheEntries\":" + CACHE.size() + "}", "application/json");

      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        reply(x, 500, "{\"error\":\"request interrupted\"}", "application/json");

      } finally {
        long n = System.nanoTime() - start;
        requests.incrementAndGet();
        durations.add(n / 1_000_000_000.0);
        if (durations.size() > 2000) {
          durations.remove(0);
        }
        System.out.printf(
          "event=profile_request duration_seconds=%.4f cache_entries=%d leak=%s%n",
          n / 1_000_000_000.0, CACHE.size(), leak
        );
      }
    });

    s.createContext("/metrics", x -> {
      MemoryMXBean mm = ManagementFactory.getMemoryMXBean();
      long used = mm.getHeapMemoryUsage().getUsed();
      long max = mm.getHeapMemoryUsage().getMax();
      long gcCount = 0, gcMs = 0;
      for (GarbageCollectorMXBean g : ManagementFactory.getGarbageCollectorMXBeans()) {
        if (g.getCollectionCount() > 0) gcCount += g.getCollectionCount();
        if (g.getCollectionTime() > 0) gcMs += g.getCollectionTime();
      }
      List<Double> ds;
      synchronized (durations) { ds = new ArrayList<>(durations); }
      Collections.sort(ds);
      double p95 = ds.isEmpty() ? 0 : ds.get(Math.min(ds.size() - 1, (int) Math.ceil(ds.size() * 0.95) - 1));

      String m =
        "jvm_memory_used_bytes{area=\"heap\"} " + used + "\n" +
        "jvm_memory_max_bytes{area=\"heap\"} " + max + "\n" +
        "jvm_gc_collection_seconds_count " + gcCount + "\n" +
        "jvm_gc_collection_seconds_sum " + (gcMs / 1000.0) + "\n" +
        "northstar_profile_p95_seconds " + p95 + "\n" +
        "northstar_cache_entries " + CACHE.size() + "\n" +
        "northstar_cache_leak_enabled " + (leak ? 1 : 0) + "\n";
      reply(x, 200, m, "text/plain; version=0.0.4");
    });

    System.out.println("INC-004B Java cache service listening on :8080");
    s.start();
  }
}