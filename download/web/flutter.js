// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * This script loads the Flutter web app.
 */
window.addEventListener('load', function(ev) {
  // Detect if we've already loaded
  const _flutter = window._flutter || {};
  window._flutter = _flutter;
  if (_flutter.loader) {
    return;
  }

  const baseURI = document.baseURI;
  if (baseURI == null) {
    console.warn('Cannot determine base URI for Flutter app (document.baseURI not supported)');
  }

  /**
   * Initializes the web Flutter engine for the app that lives at [baseUrl].
   */
  _flutter.loader = {
    /**
     * Initializes the Flutter web engine.
     *
     * @param {*} options
     * Options to control how Flutter is loaded
     *
     * @return {Promise<EngineInitializer>}
     * A promise resolving to the EngineInitializer. The EngineInitializer
     * is a JavaScript object that exposes a method to initialize the Flutter engine.
     */
    loadEntrypoint: function(options) {
      const entrypointUrl = options && options.entrypointUrl ? options.entrypointUrl : 'main.dart.js';
      if (baseURI != null) {
        if (options.serviceWorker) {
          navigator.serviceWorker.register(baseURI + 'flutter_service_worker.js?v=' + options.serviceWorker.serviceWorkerVersion);
        }
      }

      return new Promise((resolve, reject) => {
        try {
          let script = document.createElement('script');
          script.src = entrypointUrl;
          script.type = 'text/javascript';
          script.addEventListener('load', function() {
            // The entry point JS has loaded. At this point we know that the Flutter
            // engine is ready to receive messages.
            resolve({
              /**
               * Initializes the Flutter engine.
               *
               * @return {Promise<AppRunner>}
               * A promise resolving to the AppRunner. The AppRunner is a JavaScript object
               * that exposes methods to control the Flutter app.
               */
              initializeEngine: function() {
                return new Promise((resolve, reject) => {
                  if (window.flutterConfiguration) {
                    self.flutterConfiguration.assetBase = baseURI;
                  }
                  resolve(window._flutter_web_create_app());
                });
              },
            });
          });
          document.body.appendChild(script);
        } catch (e) {
          reject(e);
        }
      });
    }
  };
});