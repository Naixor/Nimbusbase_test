// Generated by CoffeeScript 1.7.1
(function() {
  var app;

  app = angular.module('Realtime', []);

  app.controller('realtimeController', function($scope) {
    var Docs, appReady, edit1, edit2, fileLoaded;
    Docs = {};
    edit1 = document.getElementById('editer1');
    edit2 = document.getElementById('editer2');
    $scope.realtimeData = "Loading...";
    $scope.authorized = false;
    $scope.shared = false;
    $scope.isLoaded = false;
    $scope.realtimefile = {};
    $scope.femail = "";
    $scope.users = [];
    $scope.authorize = function() {
      var objAuth;
      objAuth = {
        "GDrive": {
          "key": "460727743836-sd4rpc7j65lr827sc5dokmmndhqhi48q.apps.googleusercontent.com",
          "scope": "https://www.googleapis.com/auth/drive",
          "app_name": "gdrive_realtime_test"
        },
        "Dropbox": {
          "key": "",
          "secret": "",
          "app_name": ""
        },
        "synchronous": true
      };
      Nimbus.Auth.setup(objAuth);
      Nimbus.Auth.authorize('GDrive');
      return Nimbus.Auth.authrized_callback = function() {
        return console.log("Authorized sucess!");
      };
    };
    $scope.shareClient = function() {
      Nimbus.Client.GDrive.add_share_user_real($scope.femail, function() {
        return console.log("add real share:" + $scope.femail);
      });
      return window.c_file.id;
    };
    $scope.getShareUser = function() {
      return Nimbus.Client.GDrive.get_shared_users_real(function(users) {
        var user, _i, _len;
        console.log(users);
        for (_i = 0, _len = users.length; _i < _len; _i++) {
          user = users[_i];
          $scope.users.push(user);
        }
        return $scope.$apply();
      });
    };
    fileLoaded = function(doc) {
      var string;
      string = doc.getModel().getRoot().get('todo');
      edit2.value = string.get("text");
      return gapi.drive.realtime.databinding.bindString(string.get("text", edit2));
    };
    appReady = function() {
      if (Nimbus.Client.GDrive.check_auth) {
        window.showChangeText = edit2;
        $scope.authorized = true;
        console.log("c_file.id:" + window.c_file.id);
        $scope.realtimeData = window.todo.get("text");
        Nimbus.Model.Realtime.set_objectchanged_callback(function(e) {
          console.log("changed!");
          return edit2.value = window.todo.get("text");
        });
        Nimbus.Client.GDrive.get_shared_users_real(function(users) {
          var user, _i, _len;
          console.log(users);
          $scope.users = [];
          for (_i = 0, _len = users.length; _i < _len; _i++) {
            user = users[_i];
            $scope.users.push(user);
          }
          return $scope.$apply();
        });
        Nimbus.Client.GDrive.getFile(c_file.id, function(para) {
          return Nimbus.Client.GDrive.readFile(para.selfLink, function(readFile) {
            return window.readFile = readFile;
          });
        });
        edit1.onkeyup = function(e) {
          return window.todo.set("text", edit1.value);
        };
        return window.startRealtime(function() {
          return $scope.isLoaded = true;
        });
      } else {
        alert("You have not authorize!");
        return $scope.authorized = false;
      }
    };
    return Nimbus.Auth.set_app_ready(appReady);
  });

  window.loadFunc = function() {
    var objAuth;
    objAuth = {
      "GDrive": {
        "key": "460727743836-sd4rpc7j65lr827sc5dokmmndhqhi48q.apps.googleusercontent.com",
        "scope": "https://www.googleapis.com/auth/drive",
        "app_name": "gdrive_realtime_test"
      },
      "Dropbox": {
        "key": "",
        "secret": "",
        "app_name": ""
      },
      "synchronous": true
    };
    return Nimbus.Auth.setup(objAuth);
  };

}).call(this);
