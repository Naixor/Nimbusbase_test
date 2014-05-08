// Generated by CoffeeScript 1.6.3
(function() {
  Nimbus.Auth.Dropbox_auth = {
    authenticate_dropbox: function() {
      localStorage["key"] = this.key;
      localStorage["secret"] = this.secret;
      localStorage["state"] = "Auth";
      return Nimbus.Client.Dropbox.get_request_token(this.key, this.secret, Nimbus.Client.Dropbox.authorize_token);
    },
    initialize_dropbox: function() {
      log("initialization called");
      if (location.protocol === "chrome-extension:") {
        log("Chrome edition authentication");
        chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
          if (tab.title === "API Request Authorized") {
            chrome.tabs.remove(tabId);
            return Nimbus.Client.Dropbox.get_access_token(function(data) {
              localStorage["state"] = "Working";
              if (Nimbus.Auth.authorized_callback != null) {
                Nimbus.Auth.authorized_callback();
              }
              Nimbus.Auth.app_ready_func();
              console.log("NimbusBase is working! Chrome edition.");
              return Nimbus.track.google.registered_user();
            });
          }
        });
      }
      if ((localStorage["state"] != null) && localStorage["state"] === "Auth") {
        return Nimbus.Client.Dropbox.get_access_token(function(data) {
          localStorage["state"] = "Working";
          if (Nimbus.Auth.authorized_callback != null) {
            Nimbus.Auth.authorized_callback();
          }
          Nimbus.Auth.app_ready_func();
          console.log("NimbusBase is working!");
          return Nimbus.track.google.registered_user();
        });
      } else {
        return Nimbus.Auth.app_ready_func();
      }
    },
    dropbox_authorized: function() {
      if (Nimbus.Auth.service === "Dropbox") {
        if (localStorage["state"] === "Working") {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    },
    logout_dropbox: function(callback) {
      var k, v, _ref;
      localStorage.clear();
      if (Nimbus.dictModel != null) {
        _ref = Nimbus.dictModel;
        for (k in _ref) {
          v = _ref[k];
          v.records = {};
        }
      }
      if (this.sync_services != null) {
        Nimbus.Auth.setup(this.sync_services);
      }
      if (callback != null) {
        return callback();
      }
    }
  };

}).call(this);