'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "bfd663eeea747e4e2b753cc9ba416d78",
"index.html": "4d10dc32d74d08dfde46547e92a5253c",
"/": "4d10dc32d74d08dfde46547e92a5253c",
"main.dart.js": "68325799291feef2ebd1aff121aff82f",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "a7a8039abe7a4fc6e94764cd2f6e495c",
"assets/AssetManifest.json": "8f5240401fcc65a2dd37f63708ed0148",
"assets/NOTICES": "76cb135dc7d0f19fbbcdb55419954211",
"assets/FontManifest.json": "6410a9cee6e4224422b5b5b0ada200f5",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_google_places/assets/google_white.png": "40bc3ae5444eae0b9228d83bfd865158",
"assets/packages/flutter_google_places/assets/google_black.png": "97f2acfb6e993a0c4134d9d04dff21e2",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/nb_utils/fonts/LineAwesome.ttf": "bcc78af7963d22efd760444145073cd3",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/images/pexels-ricardo-esquivel-1607855.png": "1dd2b045abe556e7fca0eb2b16b58223",
"assets/assets/images/playstore-icon.png": "aaabab2bbad51920219f595456175b40",
"assets/assets/images/Icon%2520awesome-history.png": "605cc968e6769e4e7ab594a8badcccb5",
"assets/assets/images/Icon%2520ionic-ios-search.png": "2d82119d6bd71d0e677f80bf7b0d4d78",
"assets/assets/images/pexels-tom-jackson-2891884.png": "cc76982102d6d8c9a1f5cbf7bcc01ab6",
"assets/assets/images/instagram.png": "ffc871aa9fd739c4af838cf2231a17ee",
"assets/assets/images/ic_launcher_foreground.png": "4d49ae1cad90cbb56427ec0daf34fcb3",
"assets/assets/images/Icon%2520awesome-history.svg": "e570ef4aa7952cc5c6cba2f03e4214b6",
"assets/assets/images/Path%25206.png": "849df083c0a3918763749f1eceb5d132",
"assets/assets/images/Icon%2520feather-map-pin.png": "3c490e0f7844e67d8d75ebd2961b05c7",
"assets/assets/images/Group%252012584.png": "69daf4f4cd96b534ce60208dc0372564",
"assets/assets/images/Group%252012546.png": "08e65d5d1bd5b8b468535751d32ba0a5",
"assets/assets/images/foreground_logo.png": "687479a1a50f8021eb48477445f01153",
"assets/assets/images/pexels-daniel-absi-680074.png": "6d2e7b160088e6d74da9e20e71d6f782",
"assets/assets/images/apple.png": "4fde67ec09895371406c69cf3fdfefcb",
"assets/assets/images/basketball-bro.png": "8cd9c7f04cd5d2ebdcdef210875aab64",
"assets/assets/images/Group%252012548.png": "840e553a6e27340bbb02496e4dd59789",
"assets/assets/images/Group%252012560.png": "faa4d6df655ff323b32679711e30b116",
"assets/assets/images/Icon%2520material-person.svg": "11bccd526579b1b148da2a8d8b6cb84e",
"assets/assets/images/Icon%2520feather-edit-2.png": "2dc0c7b89a27cf828e433fb726c0d79e",
"assets/assets/images/user_icon.png": "2aa12e954d23156725b3b90579fa2df5",
"assets/assets/images/Screenshot%25202022-09-20%2520025527.png": "ed9b2e8da79c69acc31aadb19c0e0eba",
"assets/assets/images/ic_launcher_round.png": "600c6d2c33e44cc50bab1751c8126752",
"assets/assets/images/Mask%2520Group%25201.png": "ebf60c38e591f2fde56670ddcf68fc42",
"assets/assets/images/logo.jpeg": "a41c195b46dd8da3769c9f913b083bd1",
"assets/assets/images/Group%252012499.png": "e8abad3cb56a0c00b696fb6761498ed0",
"assets/assets/images/Icon%2520material-person.png": "c082a6ffaee8b21cce4e48a689ffc7b1",
"assets/assets/images/Group%252012548.svg": "f96ba814d8c74bb9757636518ab3e9a4",
"assets/assets/images/logo-new.png": "5cd0696c5331cb76ead32587925b47bc",
"assets/assets/images/instagram-verification-badge.png": "dd10a3da870e148a106e363774ba009f",
"assets/assets/images/player.png": "66c637b63fca1417cad5fb98f5cb9c11",
"assets/assets/images/pexels-king-siberia-2277981.png": "7bc5b1c04e274b672a8cd7d26c153109",
"assets/assets/check-in-data.txt": "b83feac61a909bbf0728f487a508db09",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
