window.client = null

Nimbus.Client.Dropbox.Binary = 
  
  binary_setup: ()->
    window.binary = Nimbus.Model.setup("binary", ["name", "path", "copied", "directlink", "sharelink", "expiration"])    

  initialize_client: ()->
    log("initializing second client")

    if Nimbus.Auth.key?
      if !window.client?
        window.client = new Dropbox.Client(
          key: Nimbus.Auth.key
          secret: Nimbus.Auth.secret
          sandbox: true
        )
        
        window.client.oauth.setToken(localStorage["oauth_token"], localStorage["oauth_token_secret"])
      else
        return        
    else
      log("can't upload file with no dropbox credentials")        
  
  #upload a blob and specify a name, the name will become the path
  upload_blob: (blob, name, callback) ->
    log("upload new blob")

    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    #execute only 
    if window.client?
      new_file = binary.create({ name: name, copied: false })
      
      come_back = (error, stat)->
        console.log("wrote file to cloud")
        console.log(error, stat) 
        new_file.copied = true
        new_file.path = stat.path
        new_file.save()
        
        callback(new_file) if callback?
      
      log("file name", name)
      
      window.client.writeFile(name, blob, come_back)
      
    else
      log("client won't initialize")

  upload_file: (file, callback) ->
    log("upload new file")
    
    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    #execute only 
    if window.client?
      new_file = binary.create({ name: file.name, copied: false })
      
      come_back = (error, stat)->
        console.log("wrote file to cloud")
        console.log(error, stat) 
        new_file.copied = true
        new_file.path = stat.path
        new_file.save()
        
        callback(new_file) if callback?
      
      log("file name", file.name)
      
      window.client.writeFile(file.name, file, come_back)
      
    else
      log("client won't initialize")
  
  read_file: (binary, callback) ->
    log("read a binary file from the server")
    
    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    #execute only 
    if window.client?
      come_back = (error, data, stat)->
        console.log(error, data, stat)
        callback(data)

      window.client.readFile(binary.path, {"blob": true}, come_back)
      
    else
      log("client won't initialize")    
  
  share_link: (binary, callback) ->
    log("get the share link")
    
    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    if window.client?
      come_back = (error, data)->
        console.log(error, data)
        binary.sharelink = data.url
        binary.save()
        
        callback(data)

      console.log(binary.path)
      window.client.makeUrl(binary.path, {}, come_back)
      
  direct_link: (binary, callback) ->
    log("get the share link")
    
    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    if window.client?
      #if the last link hasn't expired, just send that back
      if binary.directlink? and new Date(binary.expiration) > new Date()
        callback({ "url": binary.directlink, "expiresAt": binary.expiration })
        
      else
        come_back = (error, url)->
          console.log(error, url)
          binary.directlink = url.url
          binary.expiration = url.expiresAt.toString()
          binary.save()
          
          callback(url)
  
        window.client.makeUrl(binary.path, {'download':true, 'downloadHack': true}, come_back)
    
  delete_file: (binary) ->
    log("delete file")
    
    Nimbus.Client.Dropbox.Binary.initialize_client()
    
    #execute only 
    if window.client?
      come_back = (error, stat)->
        binary.destroy()
      
      window.client.remove(binary.path, come_back)
      
    else
      log("client won't initialize")    