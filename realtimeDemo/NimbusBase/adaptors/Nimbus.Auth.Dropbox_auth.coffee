Nimbus.Auth.Dropbox_auth = 

  #ray's new code
  authenticate_dropbox: () ->
    
    localStorage["key"] = @key
    localStorage["secret"] = @secret
    localStorage["state"] = "Auth"
    
    Nimbus.Client.Dropbox.get_request_token( @key, @secret, Nimbus.Client.Dropbox.authorize_token )
  
  #initialization upon entry to program
  initialize_dropbox: () ->
    log("initialization called")
    
    #chrome store execution
    if location.protocol is "chrome-extension:"
      log("Chrome edition authentication")
      chrome.tabs.onUpdated.addListener( (tabId, changeInfo, tab) -> 
        if tab.title is "API Request Authorized"
          chrome.tabs.remove(tabId)
          Nimbus.Client.Dropbox.get_access_token( (data) -> 
            localStorage["state"] = "Working" 
            Nimbus.Auth.authorized_callback() if Nimbus.Auth.authorized_callback?
            
            Nimbus.Auth.app_ready_func()
            console.log("NimbusBase is working! Chrome edition.")
            Nimbus.track.google.registered_user() 

          )
      )
      
    
    if localStorage["state"]? and localStorage["state"] is "Auth" 
      Nimbus.Client.Dropbox.get_access_token( (data) -> 
        localStorage["state"] = "Working" 
        Nimbus.Auth.authorized_callback() if Nimbus.Auth.authorized_callback?
        
        Nimbus.Auth.app_ready_func()
        console.log("NimbusBase is working!")
        Nimbus.track.google.registered_user()
      )
    else
      #this should be the default execution
      Nimbus.Auth.app_ready_func()
    
  #check if Dropbox is authorized    
  dropbox_authorized: ()->
    #if localStorage["service"]?
    if Nimbus.Auth.service is "Dropbox"
      if localStorage["state"] is "Working"
        return true
      else
        return false
    else
      return false
      
  #logout, do this by clearing localStorage of the key
  logout_dropbox: (callback)->
    localStorage.clear()
    
    #clean all the models
    if Nimbus.dictModel?
      for k, v of Nimbus.dictModel
        v.records = {}
    
    if @sync_services?
      Nimbus.Auth.setup(@sync_services)
      
    callback() if callback?
