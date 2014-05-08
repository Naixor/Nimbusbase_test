// Generated by CoffeeScript 1.6.3
(function() {
  Nimbus.Client.Dropbox = {
    get_request_token: function(key, secret, callback) {
      var header, xhr;
      xhr = new XMLHttpRequest();
      xhr.open("POST", "https://api.dropbox.com/1/oauth/request_token", true);
      header = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="' + key + '",oauth_signature="' + secret + '&"';
      log(header);
      xhr.setRequestHeader("Authorization", header);
      xhr.onreadystatechange = function() {
        var data, i, k, pair, pairs, request_token, result, v, _i, _len;
        if (this.readyState === 4) {
          if (this.status === 200) {
            data = this.response;
            log(data);
            pairs = data.split(/&/);
            request_token = {};
            for (_i = 0, _len = pairs.length; _i < _len; _i++) {
              i = pairs[_i];
              pair = i.split(RegExp("="), 2);
              request_token[pair[0]] = pair[1];
            }
            log("Token result", request_token);
            for (k in request_token) {
              v = request_token[k];
              localStorage[k] = v;
            }
            window.request_token = request_token;
            if (callback != null) {
              return callback(request_token);
            }
          } else {
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            return error(result, this.status, this);
          }
        }
      };
      return xhr.send();
    },
    authorize_token: function(request_token) {
      var auth_url, ref, return_url;
      log("authorize url", document.URL);
      if (document.URL.slice(0, 4) === "file" && (typeof cordova !== "undefined" && cordova !== null)) {
        log("Phonegap login");
        auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=" + request_token.oauth_token;
        ref = window.open(auth_url, '_blank', 'location=yes');
        window.ref = ref;
        window.auth_count = 0;
        ref.addEventListener('loadstop', function(event) {
          console.log(event);
          console.log("event", event.url.indexOf("https://www.dropbox.com/1/oauth/authorize"));
          if (event.url.indexOf("https://www.dropbox.com/1/oauth/authorize") >= 0) {
            window.auth_count = window.auth_count + 1;
            if (window.auth_count === 2) {
              Nimbus.Auth.Dropbox_auth.initialize_dropbox();
              return window.ref.close();
            }
          }
        });
        return ref.addEventListener('exit', function(event) {
          return Nimbus.Auth.logout_dropbox();
        });
      } else if (document.URL.slice(0, 4) === "http") {
        return_url = "&oauth_callback=" + encodeURIComponent(document.URL);
        auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=" + request_token.oauth_token + return_url;
        return location.replace(auth_url);
      } else if (document.URL.slice(0, 6) === "chrome") {
        log("chrome app!");
        auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=" + request_token.oauth_token;
        return chrome.tabs.create({
          "url": auth_url,
          "selected": true
        }, function(tab) {
          return log("tab created", tab.id);
        });
      } else {
        auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=" + request_token.oauth_token;
        return location.replace(auth_url);
      }
    },
    get_access_token: function(callback) {
      var auth_string, oauth_token, oauth_token_secret, xhr;
      oauth_token = localStorage["oauth_token"];
      oauth_token_secret = localStorage["oauth_token_secret"];
      auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="' + Nimbus.Auth.key + '",oauth_token="' + oauth_token + '",oauth_signature="' + Nimbus.Auth.secret + "&" + oauth_token_secret + '"';
      log("auth_string:", auth_string);
      xhr = new XMLHttpRequest();
      xhr.open("POST", "https://api.dropbox.com/1/oauth/access_token", true);
      xhr.setRequestHeader("Authorization", auth_string);
      xhr.onreadystatechange = function() {
        var access_token, data, i, k, pair, pairs, result, v, _i, _len;
        if (this.readyState === 4) {
          if (this.status === 200) {
            data = this.response;
            log(data);
            pairs = data.split(/&/);
            access_token = {};
            for (_i = 0, _len = pairs.length; _i < _len; _i++) {
              i = pairs[_i];
              pair = i.split(RegExp("="), 2);
              access_token[pair[0]] = pair[1];
            }
            log("Access result", access_token);
            for (k in access_token) {
              v = access_token[k];
              localStorage[k] = v;
            }
            window.access_token = access_token;
            if (callback != null) {
              return callback(access_token);
            }
          } else {
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            return log(result, this.status, this);
          }
        }
      };
      return xhr.send();
    },
    send_request: function(method, url, body, success, failure) {
      var auth_string, key, oauth_token, oauth_token_secret, pList, xhr;
      oauth_token = localStorage["oauth_token"];
      oauth_token_secret = localStorage["oauth_token_secret"];
      auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="' + Nimbus.Auth.key + '",oauth_token="' + oauth_token + '",oauth_signature="' + Nimbus.Auth.secret + "&" + oauth_token_secret + '"';
      log("auth_string:", auth_string);
      xhr = new XMLHttpRequest();
      xhr.open(method, url, true);
      xhr.setRequestHeader("Authorization", auth_string);
      xhr.onreadystatechange = function() {
        var result;
        if (this.readyState === 4) {
          if (this.status === 200) {
            result = this.response;
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            log("REQUEST RESULT", result);
            if (success != null) {
              success(result);
            }
          } else {
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            log(result, this.status, this);
            if (failure != null) {
              failure(result);
            }
          }
          if (window.current_syncing != null) {
            return window.current_syncing.ok();
          }
        }
      };
      if (method === "POST") {
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (body) {
          pList = [];
          for (key in body) {
            pList.push(encodeURIComponent(key) + "=" + encodeURIComponent(body[key]));
          }
          body = (pList.length > 0 ? pList.join("&").replace(/%20/g, "+") : null);
        }
        log(body);
      }
      log("send request params", method, url, body, success, failure);
      if (window.current_syncing != null) {
        window.current_syncing.wait();
      }
      xhr.send(body);
      return window.xhr = xhr;
    },
    send_request_without_delay: function(method, url, body, success, failure) {
      var auth_string, key, oauth_token, oauth_token_secret, pList, xhr;
      oauth_token = localStorage["oauth_token"];
      oauth_token_secret = localStorage["oauth_token_secret"];
      auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="' + Nimbus.Auth.key + '",oauth_token="' + oauth_token + '",oauth_signature="' + Nimbus.Auth.secret + "&" + oauth_token_secret + '"';
      log("auth_string:", auth_string);
      xhr = new XMLHttpRequest();
      xhr.open(method, url, true);
      xhr.setRequestHeader("Authorization", auth_string);
      xhr.onreadystatechange = function() {
        var result;
        if (this.readyState === 4) {
          if (this.status === 200) {
            result = this.response;
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            log("REQUEST RESULT", result);
            if (success != null) {
              return success(result);
            }
          } else {
            try {
              result = JSON.parse(result);
            } catch (_error) {}
            log(result, this.status, this);
            if (failure != null) {
              return failure(result);
            }
          }
        }
      };
      if (method === "POST") {
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (body) {
          pList = [];
          for (key in body) {
            pList.push(encodeURIComponent(key) + "=" + encodeURIComponent(body[key]));
          }
          body = (pList.length > 0 ? pList.join("&").replace(/%20/g, "+") : null);
        }
        log(body);
      }
      log("send request params", method, url, body, success, failure);
      return xhr.send(body);
    },
    putFileContents: function(path, content, success, error) {
      log("putFileContents");
      return Nimbus.Client.Dropbox.send_request("PUT", "https://api-content.dropbox.com/1/files_put/sandbox" + path, content, success, error);
    },
    createFolder: function(path, success, error) {
      log("createFolder");
      return Nimbus.Client.Dropbox.send_request("POST", "https://api.dropbox.com/1/fileops/create_folder", {
        root: 'sandbox',
        path: path
      }, success, error);
    },
    deletePath: function(path, success, error) {
      log("deletePath");
      return Nimbus.Client.Dropbox.send_request("POST", "https://api.dropbox.com/1/fileops/delete", {
        root: 'sandbox',
        path: path
      }, success, error);
    },
    getFileContents: function(path, success, error) {
      log("getFileContents");
      return Nimbus.Client.Dropbox.send_request("GET", "https://api-content.dropbox.com/1/files/sandbox" + path, "", success, error);
    },
    getMetadataList: function(path, success, error) {
      log("getMetadataList");
      return Nimbus.Client.Dropbox.send_request("GET", "https://api.dropbox.com/1/metadata/sandbox" + path, "", success, error);
    },
    getAccountInfo: function(success, error) {
      log("getAccountInfo");
      return Nimbus.Client.Dropbox.send_request_without_delay("GET", "https://api.dropbox.com/1/account/info", "", success, error);
    }
  };

}).call(this);