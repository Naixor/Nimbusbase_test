Nimbus.Client.GDrive.Binary = 
  
  binary_setup: ->
    window.binary = Nimbus.Model.setup("binary", ["name", "path", "copied", "directlink", "sharelink", "expiration", "file_id"])

  initialize_client: (run)->
    log("initializing client")
      
    if Nimbus.Auth.key? and Nimbus.Auth.scope?
      if not Nimbus.Client.GDrive.check_auth()
        Nimbus.Client.GDrive.authorize Nimbus.Auth.key, Nimbus.Auth.scope, ->
          log("GDrive authorized")          
          run() if run
      else
        run() if run
    else
      log("can't upload file with no GDrive credentials")       
  
  #upload a blob and specify a name, the name will become the path
  upload_blob: (blob, name, callback) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("upload new blob")

      reader = new FileReader();
      reader.readAsBinaryString(blob);
      reader.onload = ->
        content = reader.result
        contentType = blob.type || 'application/octet-stream'
        parent = window.folder["binary_files"].id

        new_file = binary.create({'name': name})

        come_back = (file)->
          console.log("upload file to cloud")
          console.log(file) 
          new_file.copied = true
          new_file.file_id = file.id
          new_file.directlink = file.webContentLink
          new_file.save()
          
          callback(new_file) if callback?

        Nimbus.Client.GDrive.insertFile(content, name, contentType, parent, come_back)

  upload_file: (file, callback) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("upload new file")
      
      reader = new FileReader();
      reader.readAsBinaryString(file);
      reader.onload = ->
        name = file.name
        content = reader.result
        contentType = file.type || 'application/octet-stream'
        parent = window.folder["binary_files"].id

        new_file = binary.create({'name': name})

        come_back = (file)->
          console.log("upload file to cloud")
          console.log(file) 
          new_file.copied = true
          new_file.file_id = file.id
          new_file.directlink = file.webContentLink
          new_file.save()
          new_file._file = file
          
          callback(new_file) if callback?

        Nimbus.Client.GDrive.insertFile(content, name, contentType, parent, come_back)    
  
  read_file: (binary, callback) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("read metadata of a file from the server")
      
      param = 
        path: "/drive/v2/files/" + binary.file_id

      Nimbus.Client.GDrive.make_request param, (data)->
        console.log(data)
        callback(data) if callback
       
  
  share_link: (binary, callback) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("get the share link")
    
      #TODO
      callback("") if callback

  direct_link: (binary, callback) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("get the direct link")
      
      callback(binary.directlink) if callback

    
  delete_file: (binary) ->
    Nimbus.Client.GDrive.Binary.initialize_client ->
      log("delete file", binary)
            
      Nimbus.Client.GDrive.deleteFile binary.file_id, ->
        binary.destroy()