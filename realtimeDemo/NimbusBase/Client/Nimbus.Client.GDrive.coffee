#The client which write, and read and delete files from Google Drive

Nimbus.Client.GDrive = 
#window.GDrive = 

  #check if the user is currently authorized
  check_auth: () ->
    log("checking if this is authenticated")
    if location.protocol is "chrome-extension:"
      if gapi? and gapi.auth? and gapi.auth.getToken() is null and window.todo?
        token = Nimbus.Auth.GDrive.getLocalOauth2Token()
        if not token? or Nimbus.Auth.GDrive.isTokenExpires(token)
          return false
        else
          gapi.auth.setToken(token)
          return true

    gapi? and gapi.auth? and gapi.auth.getToken() isnt null and Object.keys(gapi.auth.getToken()).length isnt 0 and window.todo?
    
  #authorize the GDrive client if it's not already authorized
  authorize: (client_id, scopes, callback) ->
    log("authorized called")
   
    gapi.auth.authorize
      client_id: client_id
      scope: scopes
      immediate: false
      authuser : localStorage.authuser || 0,
      prompt : 'select_account'
    , callback
  
  #a function designed to write a text file to google Apps  
  #Sample: uplaod a test file: GDrive.insertFile("four five six", "test1.txt", "text/plain")
  #Sample: create a folder: GDrive.insertFile("", "testfolder", "application/vnd.google-apps.folder")
  insertFile: (content, title, contentType, parent, callback)-> #(parent, content, mime, success, error) ->
    log("putFileContents")
    
    boundary = "-------314159265358979323846"
    delimiter = "\r\n--" + boundary + "\r\n"
    close_delim = "\r\n--" + boundary + "--"
    
    #contentType = "text/plain"
    
    base64Data = btoa(content)
    
    metadata = { title: title, mimeType: contentType }
    metadata['parents'] =  [{"kind": "drive#fileLink", "id": parent}] if parent?
    
    multipartRequestBody = delimiter + "Content-Type: application/json\r\n\r\n" + 
      JSON.stringify(metadata) + delimiter + 
      "Content-Type: " + contentType + "\r\n" + 
      'Content-Transfer-Encoding: base64\r\n' +
      "\r\n" + base64Data + close_delim
    
    log("MULTI: ", multipartRequestBody)
    
    unless callback
      callback = (file) ->
        log "Update Complete ", file
    
    params = 
      path: "/upload/drive/v2/files"
      method: "POST"
      params:
        uploadType: "multipart"
    
      headers:
        "Content-Type": "multipart/mixed; boundary=\"" + boundary + "\""
    
      body: multipartRequestBody
    
    @make_request(params, callback)

  #delete files by file_id, but that means that you probably have to keep the file_id locally
  deleteFile: (file_id, callback) ->
    log("deletePath")
    
    unless callback
      callback = (resp) =>
        params =
          path: "/drive/v2/files/"+file_id
          method: "DELETE"
      
        @make_request(params, (data)-> log("delete complete", data))
        
        log "Delete Complete ", resp
    
    params =
      path: "/drive/v2/files/"+file_id+"/trash"
      method: "POST"
      
    @make_request(params, callback)

  #get the file object for the corresponding id, doesn't actually get file content
  getFile: (file_id, callback) ->
    log("getFileContents")
    
    unless callback
      callback = (resp) ->
        log "Read Complete ", resp    
    
    params =
      path: "/drive/v2/files/"+file_id
      method: "GET"
      
    @make_request(params, callback)

  #read file get the actual file contents by download url
  #need to save the download link on the files
  readFile: (url, callback) ->
    unless callback
      callback = (resp) ->
        log "Read Complete ", resp
    
    accessToken = gapi.auth.getToken().access_token
    xhr = new XMLHttpRequest()
    xhr.open "GET", url
    xhr.setRequestHeader "Authorization", "Bearer " + accessToken
    xhr.onload = ->
      callback xhr.responseText
      window.current_syncing.ok() if window.current_syncing?

    xhr.onerror = ->
      callback null
    
    window.current_syncing.wait() if window.current_syncing?
    xhr.send()

  #update a file's content, didn't test with folder
  updateFile: (content, title, contentType, file_id, folder_id, callback)->
    log("updateFileContents")
    
    boundary = "-------314159265358979323846"
    delimiter = "\r\n--" + boundary + "\r\n"
    close_delim = "\r\n--" + boundary + "--"
    contentType = "text/html"
    metadata = mimeType: contentType
    
    base64Data = btoa(content)
    
    metadata = { title: title, mimeType: contentType }
    multipartRequestBody = delimiter + "Content-Type: application/json\r\n\r\n" + 
      JSON.stringify(metadata) + delimiter + 
      "Content-Type: " + contentType + "\r\n" + 
      'Content-Transfer-Encoding: base64\r\n' +
      "\r\n" + base64Data + close_delim
      
    unless callback
      callback = (file) ->
        log "Update Complete ", file
    
    params =
      path: "/upload/drive/v2/files/"+file_id
      method: "PUT"
      params:
        fileId: file_id
        uploadType: "multipart"
    
      headers:
        "Content-Type": "multipart/mixed; boundary=\"" + boundary + "\""
    
      body: multipartRequestBody
    
    @make_request(params, callback)
  
  #get a list of metadata for a files matching query, query style defined here https://developers.google.com/drive/search-parameters
  getMetadataList: (query, callback) ->
    log("getMetadataList")
    
    unless callback
      callback = (file) ->
        log "List of files", file
    
    params =
      path: "/drive/v2/files"
      method: "GET"
      params:
        q: query
    
    @make_request(params, callback)
    
  #put a delay op around each request
  make_request: (params, callback) -> 
    params['callback'] = (data)->
      callback(data) if callback?
      window.current_syncing.ok() if window.current_syncing?
    
    window.current_syncing.wait() if window.current_syncing? #take into account waiting
    gapi.client.request params
  
  #***************************************
  #This section is for the permission stuff
  #****************************************

  #get current user
  get_current_user: (callback)->
    log("get current user")
    
    process = (file) =>
      log "About called ", file
      
      user = {}
      user.name = file["user"].displayName
      user.id = file["user"].permissionId
      user.pic = file["user"].picture.url if file["user"].picture?
      
      callback(user) if callback?
      
    params =
      path: "/drive/v2/about"
      method: "GET"
    
    @make_request(params, process)    

  #get current user
  # from plus one, this will have user id
  get_current_user_info: (callback)->
    log("get current user")
    
    process = (user) =>
      callback(user) if callback?
      
    params =
      path: "/plus/v1/people/me"
      method: "GET"
    
    @make_request(params, process)    
  
  #give another user access to the data in this entire app 
  #https://developers.google.com/drive/v2/reference/permissions/insert
  add_share_user: (email, callback) ->
    log("&&& add share user")
    
    process = (person) =>
      log "Add Share user Complete ", person
      
      p = id: person.id, name: person.name, role: person.role
      p["pic"] = person.photoLink if person.photoLink?
      
      callback(p) if callback?
    
    app_folder_id = window.folder['binary_files'].id
    
    params =
      path: "/drive/v2/files/"+ app_folder_id + "/permissions"
      method: "POST"
      params:
        fileId: app_folder_id
    
      body:
        role: "writer"
        type: "user"
        value: email
    
    @make_request(params, process)

  #give another user access to the data in this entire app 
  #https://developers.google.com/drive/v2/reference/permissions/insert
  add_share_user_real: (email, callback, file_id) ->
    log("&&& add share user")
    fid = if file_id then file_id else window.c_file.id
    process = (person) =>
      log "Add Share user Complete ", person
      
      p = id: person.id, name: person.name, role: person.role
      p["pic"] = person.photoLink if person.photoLink?
      
      callback(p) if callback?
    
    params =
      path: "/drive/v2/files/"+ fid + "/permissions"
      method: "POST"
      params:
        fileId: fid
    
      body:
        role: "writer"
        type: "user"
        value: email
    
    @make_request(params, process)    
    
  #remove a user from sharing this app's data  
  remove_share_user: (id, callback) ->
    log("&&& remove a user from sharing this app")

    app_folder_id = window.folder['binary_files'].id

    unless callback
      callback = (file) ->
        log "Permission Removal Complete ", file
    
    #create a remove user function to be called alter
    params =
      path: "/drive/v2/files/"+ app_folder_id + "/permissions/" + id
      method: "DELETE"
    
    @make_request(params, callback)

  #remove a user from sharing this app's data  
  remove_share_user_real: (id, callback,file_id) ->
    log("&&& remove a user from sharing this app")

    unless callback
      callback = (file) ->
        log "Permission Removal Complete ", file
    file_id = if file_id then file_id else window.c_file.id
    #create a remove user function to be called alter
    params =
      path: "/drive/v2/files/"+ file_id + "/permissions/" + id
      method: "DELETE"
    
    @make_request(params, callback)

  # get authorized user email
  get_user_email: ->
    return window.user_email if window.user_email?

    access_token = gapi.auth.getToken().access_token
    data = null
    # must be synchronous
    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if xhr.readyState is 4
        if xhr.status is 200
          data = JSON.parse(xhr.responseText)
        else
          log("get user email failed with status #{xhr.status}")

    xhr.open("GET",
      "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=#{access_token}", false)
    xhr.send(null)

    if data?.email?
      window.user_email = data.email
      return data.email
    return null

  #get a list of users you can share from for this app
  get_shared_users_real: (callback) ->
    log("&&& get shared users")

    process = (file) =>
      log "Update Complete ", file
      
      permissions = []
      
      for p in file.items
        perm = id: p.id, name: p.name, role: p.role
        perm["pic"] = p.photoLink if p.photoLink?
        
        permissions.push(perm)
      
      log("permissions", permissions)
        
      callback(permissions) if callback?
    
    params =
      path: "/drive/v2/files/"+ window.c_file.id + "/permissions"
      method: "GET"
   
    @make_request(params, process)
    
  #get a list of users you can share from for this app
  get_shared_users: (callback) ->
    log("&&& get shared users")

    app_folder_id = window.folder['binary_files'].id

    process = (file) =>
      log "Update Complete ", file
      
      permissions = []
      
      for p in file.items
        perm = id: p.id, name: p.name, role: p.role
        perm["pic"] = p.photoLink if p.photoLink?
        
        permissions.push(perm)
      
      log("permissions", permissions)
        
      callback(permissions) if callback?
    
    params =
      path: "/drive/v2/files/"+ app_folder_id + "/permissions"
      method: "GET"
   
    @make_request(params, process)
  
  get_app_folders: (callback) ->
    log("&&& get app folders")
    Nimbus.Client.GDrive.getMetadataList("mimeType = 'application/vnd.google-apps.folder' and title = '#{ Nimbus.Auth.app_name }'", (data)->
      
      log(data)
      
      folders = data.items
      spaces = []
      if data.items?
        for f in folders
          s = {}
          s.id = f.id
          s.owner = f.ownerNames[0]
          spaces.push s
      
      log(spaces)
      
      callback(spaces) if callback?
    )
    
  #input, id of the app folder to switch to
  switch_to_app_folder: (id, callback) ->
    log("###switch to app folder")

    window.folder = {}
    
    #first switch the base folder
    window.folder[Nimbus.Auth.app_name] = "title":Nimbus.Auth.app_name, "id": id
    
    window.current_syncing = new DelayedOp =>
      callback() if callback?    
    
    #set the main folder in localstorage so refresh comes back to it
    localStorage["main_folder_id"] = id
    
    #redo initialization
    Nimbus.Client.GDrive.getMetadataList("mimeType = 'application/vnd.google-apps.folder'", (data)-> 
      a = data.items
      
      #put in the correct folders wtih the  app folder as root
      log("###rewriting folders", a)
      for x in a
        log(x)
        window.folder[x.title] = x if x.parents.length > 0 and ( x.parents[0].id is id )
      
      #clean all the models
      if Nimbus.dictModel?
        for k, v of Nimbus.dictModel
          v.records = {}
      
    )
    
    window.current_syncing.ready()
    
  #change file
  switch_to_app_file_real : (id,callback)->
    localStorage.last_opened_workspace = id
    window.current_syncing = new DelayedOp =>
      callback() if callback?  
    Nimbus.Share.getFile(id,(data)->
      return unless data.id
      # switch c_file
      window.c_file = data

      # clean dictmodels
      if Nimbus.dictModel?
        for k,v of Nimbus.dictModel
          v.records = {}
      
      gapi.drive.realtime.load(id, onFileLoaded, initializeModel, handleErrors)
    )
    window.current_syncing.ready()
  build_params: (obj) ->
      params_arr = for k, v of obj
          "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
      params_arr.join("&")

  extract_params_from_url: ->
    params = {}
    queryString = location.hash.substring(1)
    regex = /([^&=]+)=([^&]*)/g
    params[decodeURIComponent(m[1])] = decodeURIComponent(m[2]) while m =
      regex.exec(queryString)
    params


  request_access_token: -> 
    redirect_uri = Nimbus.Auth.redirect_uri || window.location.protocol+'//'+window.location.host+window.location.pathname # strip slash in the end
    params =
      response_type: "token"
      client_id: Nimbus.Auth.key
      'redirect_uri' : redirect_uri
      scope: Nimbus.Auth.scope
      state: "gdrive_get_access_token"
      prompt: "select_account"
    params_str = Nimbus.Client.GDrive.build_params(params)
    url = "https://accounts.google.com/o/oauth2/auth?#{params_str}"
    
    window.open(url, "_self")

  request_validate_token: (token) ->
    xhr = new XMLHttpRequest()
    data = null
    xhr.onreadystatechange = ->
      if xhr.readyState is 4
        if xhr.status in [200, 400]
          data = JSON.parse(xhr.responseText)
        else
          log("validate access token failed with status #{xhr.status}")

    xhr.open("GET",
      "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=#{token}",false)
    xhr.send(null)
    data

  is_token_validate: (token) ->
    result = false
    data = @request_validate_token(token)
    return false unless data?
    if "error" not of data and data?.audience == Nimbus.Auth.key
      result = true
    result

  handle_auth_redirected: ->
    # not all browsers support this api
    # see: http://caniuse.com/#feat=history
    history.replaceState?("", document.title, window.location.pathname)

  is_auth_redirected: ->
    params = @extract_params_from_url()
    if params.state is "gdrive_get_access_token" and "token_type" of params and params.token_type is "Bearer"
      if params.authuser
        localStorage.authuser = params.authuser
      return true
    return false


