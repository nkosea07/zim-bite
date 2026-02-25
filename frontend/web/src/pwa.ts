// Service worker registration for PWA / offline support.
// Optimised for low-bandwidth environments (Zimbabwe mobile networks).

export function registerServiceWorker(): void {
  if (!('serviceWorker' in navigator)) return;

  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register('/sw.js', { scope: '/' })
      .then((registration) => {
        // Check for updates every 60 seconds (background refresh without reloading)
        setInterval(() => registration.update(), 60_000);

        registration.addEventListener('updatefound', () => {
          const worker = registration.installing;
          if (!worker) return;
          worker.addEventListener('statechange', () => {
            if (worker.state === 'installed' && navigator.serviceWorker.controller) {
              dispatchUpdateAvailable();
            }
          });
        });
      })
      .catch((err) => {
        console.warn('[ZimBite] Service worker registration failed:', err);
      });
  });
}

// Emits a custom event that the UI can listen to for showing an "Update available" banner
function dispatchUpdateAvailable(): void {
  window.dispatchEvent(new CustomEvent('zimbite:sw-update-available'));
}

// Connectivity helpers — used by API client to decide whether to show offline banners
export function isOnline(): boolean {
  return navigator.onLine;
}

export function onConnectivityChange(callback: (online: boolean) => void): () => void {
  const onOnline = () => callback(true);
  const onOffline = () => callback(false);
  window.addEventListener('online', onOnline);
  window.addEventListener('offline', onOffline);
  return () => {
    window.removeEventListener('online', onOnline);
    window.removeEventListener('offline', onOffline);
  };
}
