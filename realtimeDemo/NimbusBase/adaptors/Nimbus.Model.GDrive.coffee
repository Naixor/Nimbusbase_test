window.nimbus_error = []

Nimbus.Model.GDrive = 

  cloudcache: {}
  last_hash: ""
  hash: ""

  #local, js object
  #cloud, stringified json

  #todo: need to remove timestamp from this
  toCloudStructure: (object) ->
    log("local to cloud structure")
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
    
    #get the parent
    parent_name = object.parent.name
    parent = window.folder[parent_name].id
    
    Nimbus.Client.GDrive.insertFile(@toCloudStructure(object), object.id, "text/plain", parent, (data)-> 
      log("logging data inserted", data) 
      
      window.currently_syncing = true 
      object.gid = data.id
      object.time = data.modifiedDate
      object.synced = true
      object.save()
      window.currently_syncing = false 
    )
    
  delete_from_cloud: (object_id, callback) ->
    log("delete from cloud", object_id)
    #log("delete route", "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object_id}.txt")
    
    #if the id is there, delete via id, else find with local id and then delete
    Nimbus.Client.GDrive.getMetadataList( "title = '#{object_id}'", (data)-> 
      log("data", data)
      #check if there is items
      if data.items.length > 0
        id = data.items[0].id
      
        Nimbus.Client.GDrive.deleteFile(id)
        callback() if callback?
      else
        log("file to be deleted not there")
    )

  update_to_cloud: (object, callback) ->
    log("updated to cloud", object.name)
    
    #get the parent
    parent_name = object.parent.name
    parent = window.folder[parent_name].id
    
    update_comback = (data) =>
      log("logging data inserted", data) 
      
      window.currently_syncing = true 
      object.time = data.modifiedDate
      object.save()
      object.synced = true
      window.currently_syncing = false 
    
    comeback = (data)=> 
      id = data.items[0].id
      
      Nimbus.Client.GDrive.updateFile(@toCloudStructure(object), object.id, "text/plain", id, parent, (data)-> 
        log("logging data inserted", data) 
        
        window.currently_syncing = true
        object.time = data.modifiedDate
        object.save()
        window.currently_syncing = false 
      )        
      
    #if there is a google id, just update, else, find and update
    if object.gid?
      Nimbus.Client.GDrive.updateFile(@toCloudStructure(object), object.id, "text/plain", object.gid, parent, (data)-> 
        log("logging data updated", data)
        
        window.currently_syncing = true 
        object.time = data.modifiedDate
        object.save()
        window.currently_syncing = false 
      )
    else
      Nimbus.Client.GDrive.getMetadataList( "title = '#{object.id}'", comeback)

  add_from_cloud: (object_id, callback) ->
    log("add from cloud GDrive", object_id) 
    
    #function for processing data
    process_data = (data)=> 
      log("cloud url data", JSON.parse(data)) 
      
      window.currently_syncing = true 
      converted = @fromCloudStructure(data)
      x = @init( converted )
      x.synced = true #synced should always be true for a cloud to local entity
      x.time = @cloudcache[object_id].time
      x.save()
      window.currently_syncing = false 
  
    Nimbus.Client.GDrive.getMetadataList( "title = '#{object_id}'", (data)-> 
      log("cloud read data", data)
      
      window.data = data
      
      if data.items? and data.items.length >= 1
        url = window.data.items[0].downloadUrl
        
        Nimbus.Client.GDrive.readFile(url, process_data)
      else
        log("This data is not there")  
      
    )
    
  update_to_local: (object, callback) ->
    log("update to local", object)
    
    #function for processing data
    process_data = (data)=> 
      log("cloud url data", JSON.parse(data)) 
      
      window.currently_syncing = true 
      converted = @fromCloudStructure(data)      
      x = @find(object.id)
      converted.time = @cloudcache[object.id].time
      x.updateAttributes converted
      window.currently_syncing = false 
  
    Nimbus.Client.GDrive.getMetadataList( "title = '#{object.id}'", (data)-> 
      log("cloud read data", data)
      
      window.data = data
      
      if data.error?
        window.nimbus_error.push( error: data.error, object: object )
        console.log("##ERROR writing back to local", data.error, "object: ", object)
      else
        if data.items.length >= 1
          url = window.data.items[0].downloadUrl
          
          Nimbus.Client.GDrive.readFile(url, process_data)
        else
          log("This data is not there")  
      
    )

  sync_all: (cb)->
    log("syncs all the data, normally happens at the start of a program or coming back from offline")

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
  
    #try
    #get all the child of the folder containing the object
    object_name = @name
    
    log("object name", object_name)
    
    #check if the folder id for this is cached, which it should be, if not, retrieve again and then retrieve it's children
    if window.folder? and window.folder[object_name]?
      folder_id = window.folder[object_name].id
      
      fill_cache = (data)=> 
        log("cloud read data", object_name, data)
        
        window.data = data
        if data.items?
          for x in data.items
            @cloudcache[x.title] = { id: x.title, time: x.modifiedDate }
            
            if x.labels.trashed
              console.log("##### this is trashed #####", x)
        else
          log("###ERROR, no return data")
      
      Nimbus.Client.GDrive.getMetadataList( "'#{folder_id}' in parents", fill_cache)
      _this.is_cloud_available = true
    else
      log("############################BIG ERROR no folder there for load from cloud")
      _this.is_cloud_available = false
    #catch error
    #  log("trying to get the folder failed, probably cuz it don't exist", error)

  get_delta: ()->
    log("get the delta for ", @name, " since last synced")
  
  extended: ->
    @sync @proxy(@real_time_sync)
    @fetch @proxy(@loadLocal)

window.folder = null
window.folder_creation = new OneOp()
window.creating = {}
window.handle_initialization = new OneOp()
window.gdrive_initialized = false

#check if the folders for each model is there, if it is, put it in a localcache for lookup, if not, create them
#should set some kind of variable here telling the rest of the program that this is still not done
#this is the root folder for the app
window.folder_initialize = (callback)->
  log("&&& folder initialize")
  
  log("Nimbus.Client.GDrive.check_auth()", Nimbus.Client.GDrive.check_auth() , "Nimbus.Auth.service", Nimbus.Auth.service)
  
  #check if there is authentication in place, and this is a GDrive app, if not, just get out
  if Nimbus.Client.GDrive.check_auth() and Nimbus.Auth.service is 'GDrive'
    log("this is authenticated and a GDrive app")
  
    # check if the folders for the apps are there by issuing a metadata request
    Nimbus.Client.GDrive.getMetadataList("mimeType = 'application/vnd.google-apps.folder'", (data)-> 
      log("#data: ", data) 
      
      #create a hashtable of data by title
      window.folder = {}
      a = data.items
      
      #iterate through the files to find the root folder
      if localStorage["main_folder_id"]?
        window.folder[Nimbus.Auth.app_name] = "title":Nimbus.Auth.app_name, "id": localStorage["main_folder_id"]
      else
        #put in the correct folders wtih the  app folder as root
        for x in a
          if x.title is c_file.id and x.owners[0].permissionId is c_file.owners[0].permissionId
            window.folder.binary_files = x

        if not window.folder["binary_files"]?
          Nimbus.Client.GDrive.insertFile("", c_file.id, "application/vnd.google-apps.folder", null, (data) ->
            log("binary_files folder data", data)
            log("binary ready callback", binary_ready_callback)
            window.folder['binary_files'] = data
            window.binary_ready_callback() if window.binary_ready_callback
            callback() if callback?
          )
        else
          log("binary ready callback", binary_ready_callback)
          window.binary_ready_callback() if window.binary_ready_callback
          callback() if callback?
    )

    #window.binary_ready_callback() if window.binary_ready_callback
