// Generated by CoffeeScript 1.6.3
(function() {
  Dropbox.AuthDriver = (function() {
    function AuthDriver() {}

    AuthDriver.prototype.url = function() {
      return 'https://some.url';
    };

    AuthDriver.prototype.doAuthorize = function(authUrl, token, tokenSecret, callback) {
      return callback('oauth-token');
    };

    AuthDriver.prototype.onAuthStateChange = function(client, done) {
      return done();
    };

    return AuthDriver;

  })();

  Dropbox.Drivers = {};

  Dropbox.Drivers.Redirect = (function() {
    function Redirect(options) {
      this.rememberUser = (options != null ? options.rememberUser : void 0) || false;
      this.scope = (options != null ? options.scope : void 0) || 'default';
      this.useQuery = (options != null ? options.useQuery : void 0) || false;
      this.receiverUrl = this.computeUrl(options);
      this.tokenRe = new RegExp("(#|\\?|&)oauth_token=([^&#]+)(&|#|$)");
    }

    Redirect.prototype.url = function() {
      return this.receiverUrl;
    };

    Redirect.prototype.doAuthorize = function(authUrl) {
      return window.location.assign(authUrl);
    };

    Redirect.prototype.onAuthStateChange = function(client, done) {
      var credentials,
        _this = this;
      this.storageKey = "dropbox-auth:" + this.scope + ":" + (client.appHash());
      switch (client.authState) {
        case DropboxClient.RESET:
          if (!(credentials = this.loadCredentials())) {
            return done();
          }
          if (credentials.authState) {
            if (credentials.token === this.locationToken()) {
              if (credentials.authState === DropboxClient.REQUEST) {
                this.forgetCredentials();
                credentials.authState = DropboxClient.AUTHORIZED;
              }
              client.setCredentials(credentials);
            }
            return done();
          }
          if (!this.rememberUser) {
            this.forgetCredentials();
            return done();
          }
          client.setCredentials(credentials);
          return client.getUserInfo(function(error) {
            if (error) {
              client.reset();
              _this.forgetCredentials();
            }
            return done();
          });
        case DropboxClient.REQUEST:
          this.storeCredentials(client.credentials());
          return done();
        case DropboxClient.DONE:
          if (this.rememberUser) {
            this.storeCredentials(client.credentials());
          }
          return done();
        case DropboxClient.SIGNED_OFF:
          this.forgetCredentials();
          return done();
        case DropboxClient.ERROR:
          this.forgetCredentials();
          return done();
        default:
          return done();
      }
    };

    Redirect.prototype.computeUrl = function() {
      var fragment, location, locationPair, querySuffix;
      querySuffix = "_dropboxjs_scope=" + (encodeURIComponent(this.scope));
      location = Dropbox.Drivers.Redirect.currentLocation();
      if (location.indexOf('#') === -1) {
        fragment = null;
      } else {
        locationPair = location.split('#', 2);
        location = locationPair[0];
        fragment = locationPair[1];
      }
      if (this.useQuery) {
        if (location.indexOf('?') === -1) {
          location += "?" + querySuffix;
        } else {
          location += "&" + querySuffix;
        }
      } else {
        fragment = "?" + querySuffix;
      }
      if (fragment) {
        return location + '#' + fragment;
      } else {
        return location;
      }
    };

    Redirect.prototype.locationToken = function() {
      var location, match, scopePattern;
      location = Dropbox.Drivers.Redirect.currentLocation();
      scopePattern = "_dropboxjs_scope=" + (encodeURIComponent(this.scope)) + "&";
      if ((typeof location.indexOf === "function" ? location.indexOf(scopePattern) : void 0) === -1) {
        return null;
      }
      match = this.tokenRe.exec(location);
      if (match) {
        return decodeURIComponent(match[2]);
      } else {
        return null;
      }
    };

    Redirect.currentLocation = function() {
      return window.location.href;
    };

    Redirect.prototype.storeCredentials = function(credentials) {
      return localStorage.setItem(this.storageKey, JSON.stringify(credentials));
    };

    Redirect.prototype.loadCredentials = function() {
      var e, jsonString;
      jsonString = localStorage.getItem(this.storageKey);
      if (!jsonString) {
        return null;
      }
      try {
        return JSON.parse(jsonString);
      } catch (_error) {
        e = _error;
        return null;
      }
    };

    Redirect.prototype.forgetCredentials = function() {
      return localStorage.removeItem(this.storageKey);
    };

    return Redirect;

  })();

  Dropbox.Drivers.Popup = (function() {
    function Popup(options) {
      this.receiverUrl = this.computeUrl(options);
      this.tokenRe = new RegExp("(#|\\?|&)oauth_token=([^&#]+)(&|#|$)");
    }

    Popup.prototype.doAuthorize = function(authUrl, token, tokenSecret, callback) {
      this.listenForMessage(token, callback);
      return this.openWindow(authUrl);
    };

    Popup.prototype.url = function() {
      return this.receiverUrl;
    };

    Popup.prototype.computeUrl = function(options) {
      var fragments;
      if (options) {
        if (options.receiverUrl) {
          if (options.noFragment || options.receiverUrl.indexOf('#') !== -1) {
            return options.receiverUrl;
          } else {
            return options.receiverUrl + '#';
          }
        } else if (options.receiverFile) {
          fragments = Dropbox.Drivers.Popup.currentLocation().split('/');
          fragments[fragments.length - 1] = options.receiverFile;
          if (options.noFragment) {
            return fragments.join('/');
          } else {
            return fragments.join('/') + '#';
          }
        }
      }
      return Dropbox.Drivers.Popup.currentLocation();
    };

    Popup.currentLocation = function() {
      return window.location.href;
    };

    Popup.prototype.openWindow = function(url) {
      return window.open(url, '_dropboxOauthSigninWindow', this.popupWindowSpec(980, 980));
    };

    Popup.prototype.popupWindowSpec = function(popupWidth, popupHeight) {
      var height, popupLeft, popupTop, width, x0, y0, _ref, _ref1, _ref2, _ref3;
      x0 = (_ref = window.screenX) != null ? _ref : window.screenLeft;
      y0 = (_ref1 = window.screenY) != null ? _ref1 : window.screenTop;
      width = (_ref2 = window.outerWidth) != null ? _ref2 : document.documentElement.clientWidth;
      height = (_ref3 = window.outerHeight) != null ? _ref3 : document.documentElement.clientHeight;
      popupLeft = Math.round(x0 + (width - popupWidth) / 2);
      popupTop = Math.round(y0 + (height - popupHeight) / 2.5);
      return ("width=" + popupWidth + ",height=" + popupHeight + ",") + ("left=" + popupLeft + ",top=" + popupTop) + 'dialog=yes,dependent=yes,scrollbars=yes,location=yes';
    };

    Popup.prototype.listenForMessage = function(token, callback) {
      var listener, tokenRe;
      tokenRe = this.tokenRe;
      listener = function(event) {
        var match;
        match = tokenRe.exec(event.data.toString());
        if (match && decodeURIComponent(match[2]) === token) {
          window.removeEventListener('message', listener);
          return callback();
        }
      };
      return window.addEventListener('message', listener, false);
    };

    return Popup;

  })();

  Dropbox.Drivers.NodeServer = (function() {
    function NodeServer(options) {
      this.port = (options != null ? options.port : void 0) || 8912;
      this.faviconFile = (options != null ? options.favicon : void 0) || null;
      this.fs = require('fs');
      this.http = require('http');
      this.open = require('open');
      this.callbacks = {};
      this.urlRe = new RegExp("^/oauth_callback\\?");
      this.tokenRe = new RegExp("(\\?|&)oauth_token=([^&]+)(&|$)");
      this.createApp();
    }

    NodeServer.prototype.url = function() {
      return "http://localhost:" + this.port + "/oauth_callback";
    };

    NodeServer.prototype.doAuthorize = function(authUrl, token, tokenSecret, callback) {
      this.callbacks[token] = callback;
      return this.openBrowser(authUrl);
    };

    NodeServer.prototype.openBrowser = function(url) {
      if (!url.match(/^https?:\/\//)) {
        throw new Error("Not a http/https URL: " + url);
      }
      return this.open(url);
    };

    NodeServer.prototype.createApp = function() {
      var _this = this;
      this.app = this.http.createServer(function(request, response) {
        return _this.doRequest(request, response);
      });
      return this.app.listen(this.port);
    };

    NodeServer.prototype.closeServer = function() {
      return this.app.close();
    };

    NodeServer.prototype.doRequest = function(request, response) {
      var data, match, token,
        _this = this;
      if (this.urlRe.exec(request.url)) {
        match = this.tokenRe.exec(request.url);
        if (match) {
          token = decodeURIComponent(match[2]);
          if (this.callbacks[token]) {
            this.callbacks[token]();
            delete this.callbacks[token];
          }
        }
      }
      data = '';
      request.on('data', function(dataFragment) {
        return data += dataFragment;
      });
      return request.on('end', function() {
        if (_this.faviconFile && (request.url === '/favicon.ico')) {
          return _this.sendFavicon(response);
        } else {
          return _this.closeBrowser(response);
        }
      });
    };

    NodeServer.prototype.closeBrowser = function(response) {
      var closeHtml;
      closeHtml = "<!doctype html>\n<script type=\"text/javascript\">window.close();</script>\n<p>Please close this window.</p>";
      response.writeHead(200, {
        'Content-Length': closeHtml.length,
        'Content-Type': 'text/html'
      });
      response.write(closeHtml);
      return response.end;
    };

    NodeServer.prototype.sendFavicon = function(response) {
      return this.fs.readFile(this.faviconFile, function(error, data) {
        response.writeHead(200, {
          'Content-Length': data.length,
          'Content-Type': 'image/x-icon'
        });
        response.write(data);
        return response.end;
      });
    };

    return NodeServer;

  })();

}).call(this);
