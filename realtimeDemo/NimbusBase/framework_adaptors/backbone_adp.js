// Generated by CoffeeScript 1.6.3
(function() {
  Nimbus.backbone_store = function(name, model) {
    var k, k_arr, m, nimbus_model, store, v, _ref;
    log("Model on creation", model);
    this.name = name;
    m = new model;
    k_arr = [];
    _ref = m.attributes;
    for (k in _ref) {
      v = _ref[k];
      k_arr.push(k);
    }
    nimbus_model = Nimbus.Model.setup(name, k_arr);
    store = nimbus_model;
    this.data = (nimbus_model.all()) || {};
    return store;
  };

  Nimbus.backbone_sync = function(method, model, options) {
    var a, resp, s, store;
    resp = void 0;
    store = model.nimbus || model.collection.nimbus;
    window.model = model;
    switch (method) {
      case "read":
        if (model.id) {
          resp = store.find(model);
        } else {
          store.sync_all(function() {
            resp = store.all();
            return options.success(resp);
          });
          return;
        }
        break;
      case "create":
        console.log("create called");
        a = store.init(model.attributes);
        a.id = model.id;
        a.save();
        resp = a;
        break;
      case "update":
        s = store.find(model.id);
        s.updateAttributes(model.attributes);
        s.save();
        resp = s;
        break;
      case "delete":
        console.log("deletion find", store.find(model.id));
        resp = store.find(model.id).destroy();
    }
    if (resp) {
      return options.success(resp);
    } else {
      return options.error("Record not found");
    }
  };

}).call(this);