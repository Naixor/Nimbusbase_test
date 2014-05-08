#Client for Dropbox
Nimbus.Client.Dropbox = 

  get_request_token: (key, secret, callback) ->
  
    xhr = new XMLHttpRequest()
    xhr.open "POST", "https://api.dropbox.com/1/oauth/request_token", true
    header = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="'+key+'",oauth_signature="'+secret+'&"'
    
    log(header)
    xhr.setRequestHeader "Authorization", header
    
    xhr.onreadystatechange = ->
      if @readyState is 4
        if @status is 200 
          data = @response
          log(data)
          
          pairs = data.split(/&/)
          request_token = {}
          for i in pairs
            pair = i.split(RegExp("="), 2)
            request_token[pair[0]] = pair[1]   
          
          log("Token result", request_token)
          
          for k,v of request_token
            localStorage[k] = v
          
          window.request_token = request_token
          callback(request_token) if callback?
            
         else
          try
            result = JSON.parse(result)
          error result, @status, this  
        
        #if @status is 200  
        
    xhr.send()
    
  authorize_token: (request_token) ->
    log("authorize url", document.URL)
    
    #iphone
    if document.URL[0..3] is "file" and cordova?
      log("Phonegap login")
      
      auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }"
      ref = window.open(auth_url, '_blank', 'location=yes')
      window.ref = ref
      window.auth_count = 0
      ref.addEventListener('loadstop', (event)->
        console.log(event)
        console.log("event", event.url.indexOf("https://www.dropbox.com/1/oauth/authorize"))
        if event.url.indexOf("https://www.dropbox.com/1/oauth/authorize") >= 0
          window.auth_count = window.auth_count + 1
          if window.auth_count is 2
            Nimbus.Auth.Dropbox_auth.initialize_dropbox()
            
            #reinitialize Dropbox variables
            #for key,model of Nimbus.Auth.Models
            #  if key.indexOf("_Deletion") < 0
            #    Nimbus.Auth.models(model)
            
            window.ref.close()
            
      )
      ref.addEventListener('exit', (event)->
        Nimbus.Auth.logout_dropbox()
      )
  
    else if document.URL[0..3] is "http"
      return_url = "&oauth_callback=" + encodeURIComponent(document.URL)
      auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }#{ return_url }"
      location.replace(auth_url)
    
    else if document.URL[0..5] is "chrome"
      log("chrome app!")
      auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }"
      chrome.tabs.create({"url":auth_url,"selected":true}, (tab)-> log("tab created", tab.id) )
      
    else #mobile
      auth_url = "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }"
      location.replace(auth_url)
    
  get_access_token: (callback) ->
    oauth_token = localStorage["oauth_token"]
    oauth_token_secret = localStorage["oauth_token_secret"]
    
    auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="'+Nimbus.Auth.key+'",oauth_token="'+oauth_token+'",oauth_signature="'+Nimbus.Auth.secret+"&"+ oauth_token_secret+'"'
    log("auth_string:", auth_string)
    xhr = new XMLHttpRequest()
    xhr.open "POST", "https://api.dropbox.com/1/oauth/access_token", true
    xhr.setRequestHeader "Authorization", auth_string
    
    xhr.onreadystatechange = ->
      if @readyState is 4
        if @status is 200 
          data = @response
          log(data)
          
          pairs = data.split(/&/)
          access_token = {}
          for i in pairs
            pair = i.split(RegExp("="), 2)
            access_token[pair[0]] = pair[1]        
          
          log("Access result", access_token)
          
          for k,v of access_token
            localStorage[k] = v
          
          window.access_token = access_token
          callback(access_token) if callback?
          
        else
          try
            result = JSON.parse(result)
          log result, @status, this  
  
    xhr.send()
  
  send_request: (method, url, body, success, failure)->
    oauth_token = localStorage["oauth_token"]
    oauth_token_secret = localStorage["oauth_token_secret"]
  
    auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="'+Nimbus.Auth.key+'",oauth_token="'+oauth_token+'",oauth_signature="'+Nimbus.Auth.secret+"&"+ oauth_token_secret+'"'
    log("auth_string:", auth_string)
    
    xhr = new XMLHttpRequest()
    xhr.open method, url, true
    xhr.setRequestHeader "Authorization", auth_string
    xhr.onreadystatechange = ->
      if @readyState is 4
        if @status is 200 
          result = @response
          try
            result = JSON.parse(result)
          log("REQUEST RESULT", result)
          
          success(result) if success?
        else
          try
            result = JSON.parse(result)
          log result, @status, this 
          
          failure(result) if failure?
        
        window.current_syncing.ok() if window.current_syncing?

    if method is "POST"
      xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
      if body
        pList = []
        for key of body
          pList.push encodeURIComponent(key) + "=" + encodeURIComponent(body[key])
        body = (if (pList.length > 0) then pList.join("&").replace(/%20/g, "+") else null)
      
      log(body)
    
    log("send request params", method, url, body, success, failure)
    
    window.current_syncing.wait() if window.current_syncing? #take into account waiting
    
    xhr.send(body)
    window.xhr = xhr

  send_request_without_delay: (method, url, body, success, failure)->
    oauth_token = localStorage["oauth_token"]
    oauth_token_secret = localStorage["oauth_token_secret"]
  
    auth_string = 'OAuth oauth_version="1.0",oauth_signature_method="PLAINTEXT",oauth_consumer_key="'+Nimbus.Auth.key+'",oauth_token="'+oauth_token+'",oauth_signature="'+Nimbus.Auth.secret+"&"+ oauth_token_secret+'"'
    log("auth_string:", auth_string)
    
    xhr = new XMLHttpRequest()
    xhr.open method, url, true
    xhr.setRequestHeader "Authorization", auth_string
    xhr.onreadystatechange = ->
      if @readyState is 4
        if @status is 200 
          result = @response
          try
            result = JSON.parse(result)
          log("REQUEST RESULT", result)
          
          success(result) if success?
        else
          try
            result = JSON.parse(result)
          log result, @status, this 
          
          failure(result) if failure?

    if method is "POST"
      xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
      if body
        pList = []
        for key of body
          pList.push encodeURIComponent(key) + "=" + encodeURIComponent(body[key])
        body = (if (pList.length > 0) then pList.join("&").replace(/%20/g, "+") else null)
      
      log(body)
    
    log("send request params", method, url, body, success, failure)
    
    xhr.send(body)
    
  putFileContents: (path, content, success, error) ->
    log("putFileContents")    
    Nimbus.Client.Dropbox.send_request("PUT", "https://api-content.dropbox.com/1/files_put/sandbox"+path, content, success, error)

  createFolder: (path, success, error) ->
    log("createFolder")
    Nimbus.Client.Dropbox.send_request("POST", "https://api.dropbox.com/1/fileops/create_folder", { root:'sandbox', path: path }, success, error)

  deletePath: (path, success, error) ->
    log("deletePath")
    Nimbus.Client.Dropbox.send_request("POST", "https://api.dropbox.com/1/fileops/delete", { root:'sandbox', path: path }, success, error)

  getFileContents: (path, success, error) ->
    log("getFileContents")
    Nimbus.Client.Dropbox.send_request("GET", "https://api-content.dropbox.com/1/files/sandbox"+path, "", success, error)
  
  getMetadataList: (path, success, error) ->
    log("getMetadataList")
    Nimbus.Client.Dropbox.send_request("GET", "https://api.dropbox.com/1/metadata/sandbox"+path, "", success, error)

  getAccountInfo: (success, error) ->
    log("getAccountInfo")
    Nimbus.Client.Dropbox.send_request_without_delay("GET", "https://api.dropbox.com/1/account/info", "", success, error)


