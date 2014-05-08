window.one_time_sync = false

window.keys= (item)->
  keys = []
  for key, value of item
    keys.push key
  keys

Nimbus.Model.general_sync =
  
  cloudcache: {}
  
  create_object_dictionary: ()->
    dict = {}
    log("object:", @)
    
    for obj in @all()
      dict[obj.id] = obj
      
    dict
  
  #one time sync method
  sync_model_base_algo: () ->
    return if !navigator.onLine or this.is_cloud_available is false
    log("#ONE TIME SYNC ALGO RUNNING", @name)
    
    window.one_time_sync = true
    window.currently_syncing = true
    
    #convert both to sets of ids and dictionaries
    local = @create_object_dictionary()
    cloud = @cloudcache
    local_set = new Set( keys(local) )
    cloud_set = new Set( keys(cloud) )
    
    log("local_set", local_set)
    log("cloud_set", cloud_set)
    
    #delete the lists that needs to be deleted
    d_array = []
    for dlist in @DeletionStorage.all()
      @delete_from_cloud( dlist.id )
      d_array.push(dlist.id)
      dlist.destroy() # destory the deleted list afterwards
    deleted_set = new Set(d_array)
    log("deleted set", deleted_set)
    
    #process the set of ids that are there locally but not there on the cloud
    #This is the set with none in local_ids, add them
    #the other set is ones that being deleted in the cloud but not synced locally, also delete these
    log("#the set of ids that are there locally but not there on the cloud", local_set.difference( cloud_set )._set)
    for id in ( local_set.difference( cloud_set )._set ) 
      local_item = local[id]
      if local_item["synced"]? and local_item.synced
       log("id for deletion", id)
       local[id].destroy()
      else
        @add_to_cloud(local_item)
     
    #process the set of ids that are there on the cloud but not there locally
    #Add them back locally 
    #also remove the set of the already deleted stuff so it's not readded
    log("#the set of ids that are there on the cloud but not there locally minus deletions", cloud_set.difference( local_set ).difference( deleted_set )._set )
    for id in ( cloud_set.difference( local_set ).difference( deleted_set )._set )
      @add_from_cloud(id )
    
    #process the set of ids that are there in the cloud and locally
    #check their timestamps, if local > cloud, write local to cloud, if cloud > local, put it in passback to overwrite local,
    #if cloud == local, do nothing
    ##log("there on the cloud and local")
    log("#the set of ids that are there in the cloud and locally",  cloud_set.intersection( local_set )._set  )
    
    utc = []
    utl = []
    eq = []
    
    for id in ( cloud_set.intersection( local_set )._set )
      #log( "updating", local[id].name )
     
      local_time = new Date(local[id].time)
      cloud_time = new Date(cloud[id].time)
      
      #console.log (local_dict[id].name )
      
      log("local_time", local_time.toString())
      log("cloud_time", cloud_time.toString())
      
      if local_time-cloud_time is 0
        log("equal time stamp do nothin", cloud[id].title)
        eq.push(id)
      else if local_time-cloud_time > 0
        @update_to_cloud( local[id] )
        utc.push(id)
      else
        @update_to_local( local[id] )
        utl.push(id)
          
    window.currently_syncing = false
    window.one_time_sync = false

    log("updated to cloud", utc.length, utc)
    log("updated to local", utl.length, utl)
    log("equal timestamp", eq.length, eq)

  #real time sync method
  real_time_sync: (record, method, e) ->  
    
    #log("e", e)
    log("method", method)
    log("record", record)
    
    #local save
    @saveLocal(record,method)
    
    #have a flag, if we're in the middle of sync, then no cloud calls and all local?
    if window.currently_syncing
      return true
    else
      if method is "update"
        @records[record.id].time = new Date().toString()
    
    #check if online
    syncable = navigator.onLine and (localStorage["state"] is "Working" or Nimbus.Client.GDrive.check_auth())
    
    #log("syncable", syncable)    
    
    if not syncable
      console.log("syncing is not setup correctly or the instance is not online")
      return true
    
    #delete is different, everything else just call the cloud calls
    switch method
      when "destroy"
        #if the item is synced, delete it online or save a local version to sync
        if record.synced 
          if syncable
             log("deletion in cloud")
             @delete_from_cloud( record.id )
          else
            d = Deletion.init id: record.id
            d.save()
      when "create"
        @add_to_cloud(record, ()-> )
      when "update"
        @update_to_cloud(record, ()->)
      when "read"
        @update_to_local(record, ()->)
      else
        log("REAL TIME SYNCING FAILED, THIS METHOD NOT IMPLEMENTED")

  delta_update: ()->
    change = @get_delta
    
    