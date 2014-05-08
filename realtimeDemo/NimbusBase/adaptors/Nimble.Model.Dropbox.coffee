Nimbus.Model.Dropbox = 

  cloudcache: {}
  last_hash: ""
  hash: ""

  #local, js object
  #cloud, stringified json

  toCloudStructure: (object) ->
    log("local to cloud structure")
    JSON.stringify(object)

  fromCloudStructure: (value) ->
    log("changes cloud to local data in the form a dictionary")
    
    #value is assumed to be json, this might need future stuff
    value
  
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
    log("add to cloud", object.name)
    
    Nimbus.Client.Dropbox.putFileContents( "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object.id}.txt", @toCloudStructure(object), (resp)-> 
      log(object.name, "finished being added to cloud") 
      log("resp", resp)
      
      window.currently_syncing = true 
      object.time = resp.modified
      object.synced = true
      object.save()
      window.currently_syncing = false
      
      callback(resp) if callback?
    )
  
  delete_from_cloud: (object_id, callback) ->
    log("delete from cloud", object_id)
    log("delete route", "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object_id}.txt")
    
    Nimbus.Client.Dropbox.deletePath( "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object_id}.txt", ()-> 
      log("finished delete from cloud", object_id)
      callback() if callback? 
    )

  update_to_cloud: (object, callback) ->
    log("updated to cloud", object.name)
    
    Nimbus.Client.Dropbox.putFileContents( "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object.id}.txt", @toCloudStructure(object), (resp)-> 
      log(object.name, "finished being updated to cloud") 
      
      window.currently_syncing = true 
      object.time = resp.modified
      object.synced = true
      object.save()
      window.currently_syncing = false 
      
      callback(resp) if callback?
    )    

  add_from_cloud: (object_id, callback) ->
    log("add from cloud", object_id) 
    
    Nimbus.Client.Dropbox.getFileContents( "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object_id}.txt", (data) =>
      log("cloud read data", data)
      
      window.currently_syncing = true 
      converted = @fromCloudStructure(data)
      x = @init( converted )
      x.synced = true #synced should always be true for a cloud to local entity
      x.time = @cloudcache[object_id].time
      x.save()
      window.currently_syncing = false 
      
      callback(data) if callback?
    )
    
  update_to_local: (object, callback) ->
    log("update to local", object.name)
    
    Nimbus.Client.Dropbox.getFileContents( "/#{ Nimbus.Auth.app_name }"+"/#{@name}/#{object.id}.txt", (data) =>
      log("cloud read data", data)
      
      window.currently_syncing = true 
      converted = @fromCloudStructure(data)
      x = @find(object.id)
      converted.time = @cloudcache[object.id].time
      x.updateAttributes converted
      window.currently_syncing = false 
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
    log("loads all the data from the cloud locally, probably not feasible with dropbox and changes need to happen")

    @cloudcache = {}
  
    try
      #retrieve the files and put them all in the cloud cache
      Nimbus.Client.Dropbox.getMetadataList("/#{ Nimbus.Auth.app_name }/#{@name}", (data) =>
        log("call back load called")
        log("data", data)
        
        #parse out the data and put it in container
        for x in data.contents
          title = x.path
          id = title.replace( "/#{ Nimbus.Auth.app_name }/"+"#{ @name }/", "" ).replace(".txt", "")
          
          @cloudcache[id] = { id: id, time: x.modified }
        _this.is_cloud_available = true;
      ,
      (error) =>
        console.log("ERROR: error called for metadataList, folder should be created")
        _this.is_cloud_available = false;
        Nimbus.Client.Dropbox.createFolder("/#{ Nimbus.Auth.app_name }/#{@name}", (data) =>
          log("call back create folder called", data)
        )
        
        @cloudcache = {}
      )
    catch error
      _this.is_cloud_available = false;
      log("trying to get the folder failed, probably cuz it don't exist", error)

  get_delta: ()->
    log("get the delta for ", @name, " since last synced")
  
  extended: ->
    @sync @proxy(@real_time_sync)
    @fetch @proxy(@loadLocal)
