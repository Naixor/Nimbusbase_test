# Our Store is represented by a single JS object in *localStorage*. Create it
# with a meaningful name, like the name you'd give a table.
Nimbus.backbone_store = (name, model) ->
  log("Model on creation", model)
  @name = name
  
  #create a nimbus Model for this
  m = new model
  
  k_arr = []
  
  for k, v of m.attributes
    k_arr.push(k)
  
  nimbus_model = Nimbus.Model.setup(name, k_arr)
  store = nimbus_model
  @data = (nimbus_model.all()) or {}
  store

#Backbone adaptor  
Nimbus.backbone_sync = (method, model, options) ->
  resp = undefined
  store = model.nimbus or model.collection.nimbus
  
  #console.log "model", model
  #console.log "model.localStorage", store
  
  window.model = model
  switch method
    when "read"
      # resp = (if model.id then store.find(model) else { store.sync_all(); store.all(); })
      if model.id
        resp = store.find(model)
      else
        store.sync_all () -> 
          resp = store.all()
          options.success resp
        return
    when "create"
      console.log("create called")
      a = store.init(model.attributes)
      a.id = model.id
      a.save()
      resp = a
    when "update"
      s = store.find(model.id)
      s.updateAttributes(model.attributes)
      s.save()
      resp = s
    when "delete"
      console.log( "deletion find", store.find(model.id) )
      resp = store.find(model.id).destroy()
  if resp
    options.success resp
  else
    options.error "Record not found"