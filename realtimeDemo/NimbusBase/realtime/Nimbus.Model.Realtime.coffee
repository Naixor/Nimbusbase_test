REALTIME_MIMETYPE = 'application/vnd.google-apps.drive-sdk'

#Model for real time
Nimbus.Model.Realtime = 

  cloudcache: {}

  #local, js object
  #cloud, stringified json

  #todo: need to remove timestamp from this
  toCloudStructure: (object) ->
    log("local to cloud structure")
    object["type"] = @name
    JSON.stringify(object)

  #todo: need to combine cloud cache and the download for the real value
  fromCloudStructure: (value) ->
    log("changes cloud to local data in the form a dictionary")
    
    #value is assumed to be json, this might need future stuff
    JSON.parse(value)
  
  #takes two object objects and create a diff of them, return diff
  diff_objects: (previous, current) -> 
    diff = {}
    for f,v of previous
      if current[f] isnt previous[f]
        diff[f] = [current[f], previous[f]]
    
    if previous["parent_id"]? isnt current["parent_id"]?
      diff["parent_id"] = ["one of them is null"]
  
    #log("diff", diff)
  
    return diff

  add_to_cloud: (object, callback) -> #objects needs to at least have a name and listid attribute
    log("add to cloud", object)
    
    window.currently_syncing = true
    object.time = new Date().toString()
    object.type = @name
    object.synced = true
    object.save()
    window.currently_syncing = false
    
    content = @toCloudStructure(object)
    window.todo.set(object.id, content)
    
  delete_from_cloud: (object_id, callback) ->
    log("delete from cloud", object_id, window.todo.has(object_id))
    
    if window.todo.has(object_id)
      window.todo.delete(object_id)

  update_to_cloud: (object, callback) ->
    log("updated to cloud", object.id)
    
    content = @toCloudStructure(object)
    window.todo.set(object.id, content)

  add_from_cloud: (object_id, callback) ->
    log("add from cloud GDrive", object_id) 

    data = window.todo.get(object_id)
    
    window.currently_syncing = true 
    converted = @fromCloudStructure(data)
    x = @init( converted )
    x.synced = true #synced should always be true for a cloud to local entity
    x.save()
    window.currently_syncing = false
    
  update_to_local: (object, callback) ->
    log("update to local", object)

    data = window.todo.get(object.id)
    
    window.currently_syncing = true
    converted = @fromCloudStructure(data)
    x = @init( converted )
    x.synced = true #synced should always be true for a cloud to local entity
    x.save()
    window.currently_syncing = false

  sync_all: (cb)->
    log("syncs all the data, normally happens at the start of a program or coming back from offline")
    
    @load_all_from_cloud()
    @sync_model_base_algo()
    
    window.current_syncing = new DelayedOp => 
      log("call back sync called")
      window.current_syncing = new DelayedOp => 
        window.current_syncing = null
        cb() if cb?
      
      @sync_model_base_algo()

      window.current_syncing.ready()
    
    @load_all_from_cloud()
    window.current_syncing.ready()
    
  load_all_from_cloud: ()-> #retrieve all the items for the list and put it in the cloud cache
    log("loads all the data from the cloud locally")
    @cloudcache = {}

    for x in window.todo.keys()
      content = @fromCloudStructure( window.todo.get(x) )
      #log("content:", content, content.type, @name)
      if content.type is @name
        @cloudcache[x] = content

  get_delta: ()->
    log("get the delta for ", @name, " since last synced")
  
  extended: ->
    @sync @proxy(@real_time_sync)
    @fetch @proxy(@loadLocal)

  ## Hy's new code in 2014.5.6 
  ## add a realtime OBJECT_CHANGED_CALLBACK
  ## this should like this callback(current_event, obj,event)
  set_objectchanged_callback: (callback) ->
    if (typeof callback) isnt "function" 
      return console.log "Realtime OBJECT_CHANGED_CALLBACK should be function!"
    if typeof window.realtime_update_handler is "undefined"
      window.realtime_update_handler = callback
    else
      delete window.realtime_update_handler
      window.realtime_update_handler = callback

  clear_objectchanged_callback: ->
    if window.realtime_update_handler isnt "undefined"
      delete window.realtime_update_handler

### initialization and model linking code ###
window.initializeModel = (model) ->
  log("model initialization", model)
  
  field = model.createMap({})
  model.getRoot().set "todo", field

window.onFileLoaded = (doc) ->
  log("file loaded", doc)
  window.doc = doc

  process_event = (event) ->
    log("PROCESS EVENT")
    log(event)
    current_event = "NONE"
    
    obj = JSON.parse(event.oldValue) if event.oldValue?
    obj = JSON.parse(event.newValue) if event.newValue?
    
    log("object", obj)
    window.obj = obj
    
    model = Nimbus.dictModel[obj.type]
    
    if event.oldValue is null #this is a creation event
      log("add event")
      model.add_from_cloud(obj.id)
      current_event = "CREATE"
      
    else if event.newValue is null #this is a deletion event
      log("delete event")
      
      window.currently_syncing = true 
      if model.exists(obj.id)
        a = model.find(obj.id)
        a.destroy()
      window.currently_syncing = false 
      
      current_event = "DELETE"
      
    else
      log("changing the data inside a entry event")
      model.update_to_local(obj)
      
      current_event = "UPDATE"
    
    log("EVENT: ", current_event, " OBJ: ", obj)

    window.realtime_update_handler(current_event, obj,event) if window.realtime_update_handler?

  window.todo = doc.getModel().getRoot().get("todo")
  
  window.real_time_callback() if window.real_time_callback?
  
  ##todo.addEventListener(gapi.drive.realtime.EventType.VALUE_CHANGED, process_event)

  ## Hy's new code in 2014.5.6;
  ## add a callback when realtime OBJECT_CHANGED
  window.todo.addEventListener gapi.drive.realtime.EventType.VALUE_CHANGED, process_event

#create share client
window.create_share_client= () ->
  share_client = new gapi.drive.share.ShareClient(Nimbus.Auth.app_id)
  share_client.setItemIds c_file.id
  share_client.showSettingsDialog()  
  window.share_client = share_client

window.handleErrors = handleErrors = (e) ->
  if e.type is gapi.drive.realtime.ErrorType.TOKEN_REFRESH_REQUIRED
    authorizer.authorize()
  else if e.type is gapi.drive.realtime.ErrorType.CLIENT_ERROR
    alert "An Error happened: " + e.message
    #window.location.href = "/"
  else if e.type is gapi.drive.realtime.ErrorType.NOT_FOUND
    alert "The file was not found. It does not exist or you do not have read access to the file."
    #window.location.href = "/"

window.startRealtime = (callback)->
  #realtimeLoader = new rtclient.RealtimeLoader(realtimeOptions)
  #realtimeLoader.start()
  
  window.real_time_callback = callback if callback?
  
  gapi.load "auth:client,drive-realtime,drive-share", ->
    log("gapi for everything loaded")
    
    #and title='#{ Nimbus.Auth.app_name }'
    Nimbus.Client.GDrive.getMetadataList("mimeType = 'application/vnd.google-apps.drive-sdk.#{ Nimbus.Auth.app_id }'", (data)-> 
      console.log("drive apps", data)
      window.app_files = data.items
      #filter the list with folders of the same name
      i = []
      workspace = 0
      for index,x of data.items
        log(x.mimeType)
        if x.mimeType.indexOf("application/vnd.google-apps.drive-sdk") >= 0
          if localStorage.last_opened_workspace and x.id is localStorage.last_opened_workspace
            workspace = index
          i.push x
          
      log("index", i)
      
      #check if a file_name with that title is there, if it's there, load it
      if i.length > 0
        log("file there")
        c_file = i[workspace]
        window.c_file = c_file #should remove later
        
        gapi.drive.realtime.load(c_file.id, onFileLoaded, initializeModel, handleErrors)
        
      #else create that file, and load it
      else
        log("file not there")
        Nimbus.Client.GDrive.insertFile("", Nimbus.Auth.app_name, 'application/vnd.google-apps.drive-sdk', null, (data)-> 
          log("finished insertFile", data)
          window.c_file = data
          window.app_files.push(data)
          gapi.drive.realtime.load(data.id, onFileLoaded, initializeModel, handleErrors)
        )
        log("need to create file for app")
    )

#load a new file after already at a file
window.load_new_file = (file_id,callback,exception_handle)->
  window.real_time_callback = callback if callback?
  Nimbus.Share.getFile(file_id,(data)->
    window.c_file = data
    return unless data.id
    if exception_handle and exception_handle instanceof Function
      gapi.drive.realtime.load(file_id,onFileLoaded,initializeModel,exception_handle)
    else
      gapi.drive.realtime.load(file_id,onFileLoaded,initializeModel,handleErrors)

  )
  
