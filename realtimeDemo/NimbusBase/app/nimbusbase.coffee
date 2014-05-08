(->
  if not window.Nimbus?
    Nimbus = winodw.Nimbus = {}
  Nimbus = window.Nimbus
  Nimbus.version = "0.0.1"
  $ = Nimbus.$ = @jQuery or @Zepto or ->
    arguments[0]
  
  #add a model array
  Nimbus.dictModel = {}
  
  makeArray = (args) ->
    Array::slice.call args, 0
  
  isArray = (value) ->
    Object::toString.call(value) == "[object Array]"
  
  if typeof Array::indexOf == "undefined"
    Array::indexOf = (value) ->
      i = 0
      
      while i < @length
        return i  if this[i] == value
        i++
      -1
  Events =
    bind: (ev, callback) ->
      evs = ev.split(" ")
      calls = @_callbacks or (@_callbacks = {})
      i = 0
      
      while i < evs.length
        (@_callbacks[evs[i]] or (@_callbacks[evs[i]] = [])).push callback
        i++
      this
    
    trigger: ->
      args = makeArray(arguments)
      ev = args.shift()
      
      return false  unless (calls = @_callbacks)
      return false  unless (list = @_callbacks[ev])
      i = 0
      l = list.length
      
      while i < l
        return false  if list[i].apply(this, args) == false
        i++
      true
    
    unbind: (ev, callback) ->
      unless ev
        @_callbacks = {}
        return this
      
      return this  unless (calls = @_callbacks)
      return this  unless (list = calls[ev])
      unless callback
        delete @_callbacks[ev]
        
        return this
      i = 0
      l = list.length
      
      while i < l
        if callback == list[i]
          list = list.slice()
          list.splice i, 1
          calls[ev] = list
          break
        i++
      this
  
  if typeof Object.create != "function"
    Object.create = (o) ->
      F = ->
      F:: = o
      new F()
  moduleKeywords = [ "included", "extended" ]
  Class =
    inherited: ->
    
    created: ->
    
    prototype:
      initialize: ->
      
      init: ->
    
    create: (include, extend) ->
      object = Object.create(this)
      object.parent = this
      object:: = object.fn = Object.create(@::)
      object.include include  if include
      object.extend extend  if extend
      object.created()
      @inherited object
      object
    
    init: ->
      instance = Object.create(@::)
      instance.parent = this
      instance.initialize.apply instance, arguments
      instance.init.apply instance, arguments
      instance
    
    proxy: (func) ->
      thisObject = this
      ->
        func.apply thisObject, arguments
    
    proxyAll: ->
      functions = makeArray(arguments)
      i = 0
      
      while i < functions.length
        this[functions[i]] = @proxy(this[functions[i]])
        i++
    
    include: (obj) ->
      for key of obj
        @fn[key] = obj[key]  if moduleKeywords.indexOf(key) == -1
      included = obj.included
      included.apply this  if included
      this
    
    extend: (obj) ->
      for key of obj
        this[key] = obj[key]  if moduleKeywords.indexOf(key) == -1
      extended = obj.extended
      extended.apply this  if extended
      this
  
  Class::proxy = Class.proxy
  Class::proxyAll = Class.proxyAll
  Class.inst = Class.init
  Class.sub = Class.create
  Nimbus.guid = ->
    verify_guide = (g_id) ->
      for x, y of Nimbus.dictModel
        if y.exists(g_id)
          return false
      return true
    
    verified = false
    while not verified
      id = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c == "x" then r else (r & 0x3 | 0x8))
        v.toString 16
      ).toUpperCase()
      verified = verify_guide(id)
    id
  
  #Auth
  Auth = Nimbus.Auth = Class.create()
  Auth.extend
    reinitialize: ()->
      log("reintialize called")
      
      #called on reinitialization all the time
      if localStorage["last_sync_object"]?
        log("the service exists", localStorage["service"])
        sync_service = JSON.parse(localStorage["last_sync_object"])

        #for  synchronous check 
        if not Nimbus.Auth.sync_services?
          Nimbus.Auth.sync_services = {}
          Nimbus.Auth.sync_services.synchronous = sync_service.synchronous
        else
          service = Nimbus.Auth.sync_services[sync_service.service]
          if service.app_id != sync_service.app_id
            cloud = sync_service.service
            sync_service = service
            sync_service.service = cloud
            localStorage.clear()

        @setup(sync_service)
        @initialize()
  
    #the new setup only accept dictionaries as input
    setup: (sync_service) ->
      if typeof sync_service is "string"
        console.log("Current sync service", sync_service)
        #encoded api
        sync_service = JSON.parse(Base64.decode(sync_service))
      if !@app_name
        @.app_name = sync_service.app_name
      if !@app_name
        for item of sync_service
          if sync_service[item].app_name
            @.app_name = sync_service[item].app_name
            break if @.app_name
            
      #check if service exists, then it's moving to a particular service
      if sync_service.service?
        log("setup called on a service", sync_service.service)
        log("setup object", sync_service)
        
        #replicate over the objects and keys into Nimbus.Auth and localstorage
        for key, value of sync_service
          @[key] = value
       

        if Nimbus.Auth.sync_services? and Nimbus.Auth.sync_services.synchronous?
          sync_service.synchronous = Nimbus.Auth.sync_services.synchronous
        else
          sync_service.synchronous = true;  #set  true to default
        sync_service.app_name = @app_name
        localStorage["last_sync_object"] = JSON.stringify(sync_service)
        
        switch @service
          when "Dropbox"
            @extend Nimbus.Auth.Dropbox_auth
            
            @authorize = @proxy(@authenticate_dropbox)
            @initialize = @proxy(@initialize_dropbox)
            @authorized = @proxy(@dropbox_authorized)
            @logout = ()->
              @proxy(@logout_dropbox)
              @clear_storage()
              return
            Nimbus.Binary.setup(@service)
            log("service is dropbox")
            
          when "GDrive"
            @extend Nimbus.Auth.GDrive
            
            @authorize = @proxy(@authenticate_gdrive)
            @initialize = @proxy(@initialize_gdrive)
            @authorized = @proxy(@gdrive_authorized)
            @logout = ()->
              @proxy(@logout_gdrive)
              @clear_storage()
              return
            Nimbus.Binary.setup(@service)
            log("service is GDrive")
            
            Nimbus.Share.setup(@service)

          when "Realtime" 
            startRealtime(key,app_name) 
            
          else log("Invalid service name")
          
      #new multi-provider setup method
      #don't inherit until authorization happens (?)
      #structure for sync_service should be
      # Dropbox: { key, secret, app_name } 
      # GDrive: { key, scope, app_name }
      else
        log("new method for setup, the service is there")
        
        @sync_services = sync_service
        @models = {}
        
        if localStorage["service"]?
          if localStorage["service"] is "GDrive"
            service = @sync_services["GDrive"]
            service["service"] = "GDrive"
            @setup(service)
          else
            service = @sync_services["Dropbox"]
            service["service"] = "Dropbox"
            @setup(service)
          
        else
          @extend Nimbus.Auth.Multi
          
          @authorize = @proxy(@authenticate_service)
          @initialize = @proxy(@initialize_service)      
      
        return
    clear_storage: ()->
      log('Will clear localStorage or indexedDB') 
      localStorage.clear()
      PouchDB.destroy(@app_name)
      return
                
    authorized: ()->
      log("authorized not yet setup")
    
    state: ()->
      return localStorage["state"]
      
    authorize: () ->
      log("authorize not yet setup")
      
    initialize: ()->
      log("initialize not setup")
      
    authorized_callback: ()->
      log("authorized callback undefined")
        
    app_ready_func: ()->
      log("app_ready")
      
      @app_ready = true
      
    set_app_ready: (callback) ->
      log("set app ready")
      
      if @app_ready? and @app_ready
        if @service is 'GDrive'
          window.folder_initialize(callback)
        else
          callback()
      else
        cb = ()->
          if @service is 'GDrive'
            window.folder_initialize(callback)
          else
            callback()
        @app_ready_func = cb
  
    logout: ()->
      log("logout not implemented")
  
  #Client
  Client = Nimbus.Client = Class.create()
  
  #Share api
  Share = Nimbus.Share = Class.create()
  Share.extend
    setup: (sync_service) ->
      switch sync_service
        when "GDrive"
          log("share api with GDrive")
          
          @extend Nimbus.Client.GDrive
          
          @get_users = @proxy(@get_shared_users)
          @add_user = @proxy(@add_share_user)
          @remove_user = @proxy(@remove_share_user)
          @get_me = @proxy(@get_current_user)
          @get_spaces = @proxy(@get_app_folders)
          @switch_spaces = @proxy(@switch_to_app_folder)
          @switch_file_real = @proxy(@switch_to_app_file_real)
        else log("share not supported with this service")
  
    get_users: ()->
      log("users not implemented")
    
    add_user: (email)->
      log("add a user")
      
    remove_user: (id)->
      log("removed user")
  
    get_me: ()->
      log("get currently logged user")
      
    get_spaces: ()->
      log("get current spaces")
      
    switch_spaces: (id)->
      log("switch space")
  
  #Binary writing
  Binary = Nimbus.Binary = Class.create()
  Binary.extend
    setup: (sync_service) ->
      log("binary setup called")
      
      switch sync_service
        when "Dropbox"
          @extend Nimbus.Client.Dropbox.Binary
          Nimbus.Client.Dropbox.Binary.binary_setup()
          log("service is dropbox")
        when "GDrive"
          @extend Nimbus.Client.GDrive.Binary
          Nimbus.Client.GDrive.Binary.binary_setup()
          log("service is GDrive")
          
        when "Realtime"
          log("service is  Realtime")
          
        else log("Invalid service name")      

      
    upload_blob: (blob, name, callback) ->
      log("upload blob")

    upload_file: (file, callback) ->
      log("upload blob")
    
    read_file: (binary, callback) ->
      log("read file")
    
    share_link: (binary, callback) ->
      log("share link")
    
    direct_link: (binary, callback) ->
      log("direct link")
    
    delete_file: (binary) ->
      log("delete file")
  
  #DB will bind to a localstorage or other kind of db
  DB = Nimbus.DB = Class.create()
  DB.extend Events
  DB.extend
    #set listners on dbs, now only support localstorage
    setup_db: (type) ->
      log("setup db")
      
      switch type
        when "localStorage"
          Storage.prototype.setItem = (key, value) ->
            if (this is window.localStorage)
              log("local storage called")
            else
              # fallback to default action
              _setItem.apply(this, arguments)

  #Model
  Model = Nimbus.Model = Class.create()
  Model.extend Events
  Model.extend
    
    loaded: false
    
    check_loaded: () ->
      if @loaded
        return true
      else
        console.log("The model is not loaded yet! Wait for the model to be done with setup.")
        return false
    
    service_setup: (model) ->
      log("service setup model", model)
      atts = model.attributes
      
      switch Nimbus.Auth.service
        when "Dropbox"
          log("extend as Dropbox")
          model.extend Nimbus.Model.general_sync
          model.extend Nimbus.Model.Dropbox
          
          atts.push("synced")
          atts.push("time")
          model.attributes = atts
          
        when "GDrive" 
          log("extend as GDrive")
          model.extend Nimbus.Model.general_sync
          model.extend Nimbus.Model.Realtime
          
          atts.push("gid")
          atts.push("synced")
          atts.push("time")
          atts.push("type")
          model.attributes = atts
                 
        else log("Invalid service name")

      model

    setup: (name, atts, callback) ->
      
      log("model setup")
      
      model = Model.sub()
      model.name = name if name
      model.attributes = atts if atts
      #if statement to make the model synchronous or asynchronous
      if Nimbus.Auth.sync_services.synchronous? and Nimbus.Auth.sync_services.synchronous
        model.extend Nimbus.Model.LocalSync
      else
        model.extend Nimbus.Model.Local
      
      Nimbus.dictModel[name] = model
      
      if Nimbus.Auth.service? or Nimbus.Auth.sync_services? or name is "binary" or name is "binary_Deletion"
        
        log("model 1", model)      
        
        #cehck it's not a deletion model, deletion models should only be local
        if name.indexOf("_Deletion") < 0
          model = @service_setup(model)
          
          #if we're using the multi-authentication paradigm, then save the model for authentication later  
          #if Nimbus.Auth.sync_services?
          #  log("save model", name, atts)
          #  
          #  Nimbus.Auth.models[name] = model
          
      else
        log("name:", name)
        log("Please setup Nimbus.Auth first before creating models")
      
      
      #add the deletion object for this
      if name.indexOf("_Deletion") < 0
        Deletion = Nimbus.Model.setup(name + "_" + "Deletion", [ "deletion_id", "listid" ])
        Deletion.extend Nimbus.Model.Local  
        Deletion.fetch()
        model.DeletionStorage = Deletion
      
      log(model)
      
      #fetch on initialization
      if callback?
        model.fetch( () =>
          @loaded = true
          callback()
        )
      else
        model.fetch( () =>
          @loaded = true
        )      
      
      if name.indexOf("_Deletion") < 0
        Nimbus.dictModel[name] = model
      else
        delete Nimbus.dictModel[name]
        
      model
    
    created: (sub) ->
      @records = {}
      @attributes = (if @attributes then makeArray(@attributes) else [])
    
    find: (id) ->
      record = @records[id]
      throw ("Unknown record")  unless record
      record.clone()
    
    exists: (id) ->
      try
        return @find(id)
      catch e
        return false
    
    refresh: (values) ->
      values = @fromJSON(values)
      @records = {}
      i = 0
      il = values.length
      
      while i < il
        record = values[i]
        record.newRecord = false
        @records[record.id] = record
        i++
      @trigger "refresh"
      this
    
    select: (callback) ->
      result = []
      for key of @records
        result.push @records[key]  if callback(@records[key])
      @cloneArray result
    
    findByAttribute: (name, value) ->
      for key of @records
        return @records[key].clone()  if @records[key][name] == value
    
    findAllByAttribute: (name, value) ->
      @select (item) ->
        item[name] == value
    
    each: (callback) ->
      for key of @records
        callback @records[key]
    
    all: ->
      @cloneArray @recordsValues()
    
    first: ->
      record = @recordsValues()[0]
      record and record.clone()
    
    last: ->
      values = @recordsValues()
      record = values[values.length - 1]
      record and record.clone()
    
    count: ->
      @recordsValues().length
    
    deleteAll: ->
      for key of @records
        delete @records[key]
    
    destroyAll: ->
      for key of @records
        @records[key].destroy()
    
    update: (id, atts) ->
      @find(id).updateAttributes atts
    
    create: (atts) ->
      record = @init(atts)
      record.save()
    
    destroy: (id) ->
      @find(id).destroy()
    
    sync: (callback) ->
      @bind "change", callback
    
    fetch: (callbackOrParams) ->
      if not @loaded and callbackOrParams?
        @loadLocal(callbackOrParams)
      
      (if typeof (callbackOrParams) == "function" then @bind("fetch", callbackOrParams) else @trigger.apply(this, [ "fetch" ].concat(makeArray(arguments))))
    
    toJSON: ->
      @recordsValues()
    
    fromJSON: (objects) ->
      return  unless objects
      objects = JSON.parse(objects)  if typeof objects == "string"
      if isArray(objects)
        results = []
        i = 0
        
        while i < objects.length
          results.push @init(objects[i])
          i++
        results
      else
        @init objects
    
    recordsValues: ->
      result = []
      for key of @records
        result.push @records[key]
      result
    
    cloneArray: (array) ->
      result = []
      i = 0
      
      while i < array.length
        result.push array[i].clone()
        i++
      result
  
  Model.include 
    model: true
    newRecord: true
    init: (atts) ->
      @load atts  if atts
      parent_type = @parent.name
      @parent = ()->
        Nimbus.dictModel[parent_type]
      @trigger "init", this
    
    isNew: ->
      @newRecord
    
    isValid: ->
      not @validate()
    
    validate: ->
    
    load: (atts) ->
      for name of atts
        this[name] = atts[name]
    
    attributes: ->
      result = {}
      i = 0
      
      while i < @parent().attributes.length
        attr = @parent().attributes[i]
        result[attr] = this[attr]
        i++
      result.id = @id
      result
    
    eql: (rec) ->
      rec and rec.id == @id and rec.parent() == @parent()
    
    save: ->
      error = @validate()
      if error
        @trigger "error", this, error
        return false
      @trigger "beforeSave", this
      (if @newRecord then @create() else @update())
      @trigger "save", this
      this
    
    updateAttribute: (name, value) ->
      this[name] = value
      @save()
    
    updateAttributes: (atts) ->
      @load atts
      @save()
    
    destroy: ->
      @trigger "beforeDestroy", this
      delete @parent().records[@id]
      
      @destroyed = true
      @trigger "destroy", this
      @trigger "change", this, "destroy"
    
    dup: ->
      result = @parent().init(@attributes())
      result.newRecord = @newRecord
      result
    
    clone: ->
      Object.create this
    
    reload: ->
      return this  if @newRecord
      original = @parent().find(@id)
      @load original.attributes()
      original
    
    toJSON: ->
      @attributes()
    
    exists: ->
      @id and @id of @parent().records
    
    update: ->
      @trigger "beforeUpdate", this
      records = @parent().records
      records[@id].load @attributes()
      clone = records[@id].clone()
      @trigger "update", clone
      @trigger "change", clone, "update"
    
    create: ->
      @trigger "beforeCreate", this
      @id = Nimbus.guid()  unless @id
      @newRecord = false
      records = @parent().records
      records[@id] = @dup()
      clone = records[@id].clone()
      @trigger "create", clone
      @trigger "change", clone, "create"
    
    bind: (events, callback) ->
      @parent().bind events, @proxy((record) ->
        callback.apply this, arguments  if record and @eql(record)
      )
    
    trigger: ->
      try
        @parent().trigger.apply @parent(), arguments
      catch e
        log(e)
      
  
)()
