Nimbus.Auth.Multi =

  #authenticate a certain service
  authenticate_service: (service)->
    log("authenticate a single service", service)
    isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
    
    #take the service, check if it's there, and setup via the old way
    if @sync_services? and @sync_services[service]?
      x = @sync_services[service]
      x["service"] = service
      
      Nimbus.Auth.setup(x) if service is "Dropbox"
      
      if service is "GDrive"
        # for multi scope
        
        user_email_scope = 'https://www.googleapis.com/auth/userinfo.email'
        if isArray(x.scope)
          x.scope.push(user_email_scope) if user_email_scope not in x.scope
        else
          x.scope = [x.scope, user_email_scope]
        x.scope = x.scope.join(" ")
          
        if x.client_secret?
          Nimbus.Auth.setup(x)
        else
          Nimbus.Auth.setup(x)
      
      #setup the models since in multi they are not pre-setup
      for key, val of Nimbus.dictModel
        Nimbus.Model.service_setup( val )
      
      Nimbus.Auth.initialize()
      Nimbus.Auth.authorize()
   
  #check localstorage to see if a service is selected, if it is, then set it up, else don't do anything
  initialize_service: ()->
    log("initializing service")
    Nimbus.Auth.reinitialize()
    
    #Actually you probably do not need to do this since reinitialize takes care of that
      
