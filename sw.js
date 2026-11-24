// Spoke Shot offline helper (service worker).
// The first visit saves every game file on the device. After that the game opens from the saved
// copy, even with no internet, and quietly fetches any newer files for the next launch.
// Bump the CACHE number with every release: that is what tells installed copies to switch over
// on their next launch. If you add or rename files, add them to FILES too.

const CACHE = 'spoke-shot-v7';
const FILES = [
  './',
  './index.html',
  './manifest.webmanifest',
  './fonts/bagel-fat-one-400.woff2',
  './fonts/atkinson-hyperlegible-400.woff2',
  './fonts/atkinson-hyperlegible-700.woff2',
  './icons/favicon-64.png',
  './icons/apple-touch-icon.png',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/maskable-512.png',
];

self.addEventListener('install', (event) => {
  // cache: 'reload' skips the browser's own short-term cache, so a new version saves fresh files.
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(FILES.map((url) => new Request(url, { cache: 'reload' }))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith('spoke-shot-') && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;

  // Ask the network in the background and keep the saved copy fresh.
  const network = fetch(req).then(async (res) => {
    if (res && res.ok) {
      const copy = res.clone();
      const cache = await caches.open(CACHE);
      await cache.put(req, copy);
    }
    return res;
  }).catch(() => null);
  event.waitUntil(network.then(() => undefined));

  // Answer from the saved copy right away when there is one.
  event.respondWith(
    caches.match(req, { ignoreSearch: true }).then((saved) => saved || network.then((res) => {
      if (res) return res;
      if (req.mode === 'navigate') return caches.match('./index.html');
      return Response.error();
    }))
  );
});
