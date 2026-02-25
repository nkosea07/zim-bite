// ZimBite Service Worker
// Strategy:
//   - Static assets (JS/CSS/fonts/images): cache-first
//   - API calls (/api/v1/vendors, /api/v1/menu): stale-while-revalidate (low-bandwidth optimised)
//   - All other API calls: network-first with offline fallback
//   - Navigation: network-first, fallback to cached shell

const CACHE_VERSION = 'zimbite-v1';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const API_CACHE = `${CACHE_VERSION}-api`;
const SHELL_URL = '/';

const STATIC_EXTENSIONS = ['.js', '.css', '.woff', '.woff2', '.ttf', '.png', '.svg', '.ico', '.webmanifest'];
const STALE_WHILE_REVALIDATE_PATTERNS = ['/api/v1/vendors', '/api/v1/menu'];
const MAX_API_CACHE_AGE_MS = 5 * 60 * 1000; // 5 minutes

// ── Install: pre-cache app shell ─────────────────────────────────────────────
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => cache.add(SHELL_URL))
  );
  self.skipWaiting();
});

// ── Activate: purge old caches ────────────────────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k.startsWith('zimbite-') && k !== STATIC_CACHE && k !== API_CACHE)
          .map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

// ── Fetch ─────────────────────────────────────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Only intercept same-origin or known API origin requests
  if (request.method !== 'GET') return;

  if (isStaticAsset(url.pathname)) {
    event.respondWith(cacheFirst(request, STATIC_CACHE));
    return;
  }

  if (isStaleWhileRevalidate(url.pathname)) {
    event.respondWith(staleWhileRevalidate(request, API_CACHE));
    return;
  }

  if (url.pathname.startsWith('/api/')) {
    event.respondWith(networkFirstWithFallback(request, API_CACHE));
    return;
  }

  // Navigation — serve shell on miss
  if (request.mode === 'navigate') {
    event.respondWith(networkFirstWithShellFallback(request));
    return;
  }
});

// ── Strategies ────────────────────────────────────────────────────────────────

async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) {
    const cache = await caches.open(cacheName);
    cache.put(request, response.clone());
  }
  return response;
}

async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  const fetchPromise = fetch(request).then((response) => {
    if (response.ok) {
      const clone = response.clone();
      cache.put(request, addTimestamp(clone));
    }
    return response;
  }).catch(() => null);

  if (cached && !isCacheStale(cached)) {
    return cached;
  }

  const fresh = await fetchPromise;
  return fresh || cached || offlineApiResponse();
}

async function networkFirstWithFallback(request, cacheName) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await caches.match(request);
    return cached || offlineApiResponse();
  }
}

async function networkFirstWithShellFallback(request) {
  try {
    return await fetch(request);
  } catch {
    const cached = await caches.match(request);
    if (cached) return cached;
    return caches.match(SHELL_URL);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function isStaticAsset(pathname) {
  return STATIC_EXTENSIONS.some((ext) => pathname.endsWith(ext));
}

function isStaleWhileRevalidate(pathname) {
  return STALE_WHILE_REVALIDATE_PATTERNS.some((p) => pathname.startsWith(p));
}

function addTimestamp(response) {
  // Clone with X-SW-Cached header to track age
  const headers = new Headers(response.headers);
  headers.set('X-SW-Cached-At', Date.now().toString());
  return new Response(response.body, { status: response.status, headers });
}

function isCacheStale(response) {
  const cachedAt = response.headers.get('X-SW-Cached-At');
  if (!cachedAt) return false;
  return Date.now() - parseInt(cachedAt, 10) > MAX_API_CACHE_AGE_MS;
}

function offlineApiResponse() {
  return new Response(
    JSON.stringify({ offline: true, message: 'You are offline. Showing cached data.' }),
    { status: 503, headers: { 'Content-Type': 'application/json', 'X-Offline': '1' } }
  );
}
