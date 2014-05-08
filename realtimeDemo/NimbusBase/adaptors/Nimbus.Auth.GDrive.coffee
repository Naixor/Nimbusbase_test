Nimbus.Auth.GDrive =

  get_token_from_code: (code) ->
    xhr = new XMLHttpRequest()
    
    data = "code=#{ code }&client_id=#{ @key }&client_secret=#{ @client_secret }&grant_type=authorization_code&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
    
    window.data = data
    
    xhr.open("POST", "https://accounts.google.com/o/oauth2/token")
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded")
    xhr.onreadystatechange = (status, response) =>
      
      if xhr.readyState is 4
        try
          result = JSON.parse(xhr.response)
          if result["error"]
            console.log 'error'
          else
            window.plugins.childBrowser.close()
            localStorage["phonegap_token"] = JSON.stringify(result)
            localStorage["state"] = "Working"
            gapi.auth.setToken(result)
            _this.prepare_gdrive()
            Nimbus.track.google.registered_user()
        catch e
          console.log e
    xhr.send(data)
    window.xhr = xhr

  #ray's new code
  authenticate_gdrive: () ->
    log("this should bring up a prompt to initialize into GDrive")
        
    localStorage["d_key"] = @key
    localStorage["secret"] = @scope
    localStorage["state"] = "Auth"

    #if phonegap
    if document.URL[0..3] is "file" and cordova?
      log("Phonegap google login")
      
      auth_url = "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=" + @key +  "&scope=" + encodeURIComponent(@scope) + "&approval_prompt=auto&redirect_uri=urn:ietf:wg:oauth:2.0:oob";
        
      window.auth_url = auth_url
      cb = window.plugins.childBrowser;
      if cb != null
        cb.onLocationChange = (loc)->
          locChanged(loc)
        cb.onClose = ()->
          onCloseBrowser()
        cb.onOpenExternal = ()->
          onOpenExternal()
        url = auth_url+"###var sendToApp = function(_key, _val) {var iframe = document.createElement('IFRAME');iframe.setAttribute('src', _key + ':##sendToApp##' + _val);document.documentElement.appendChild(iframe);iframe.parentNode.removeChi(iframe);iframe = null;};var log=function(_mssg){sendToApp('ios-log',_mssg);}; var html = document.getElementById('code').value; log(html);";

        cb.onJSCallback = (backStr)->
          cb.code = backStr
          if backStr and backStr? and backStr isnt "(null)"
            cb.close()
            console.log("will get some toaken")
            Nimbus.Auth.get_token_from_code(backStr)

        cb.showWebPage(url)
    #chrome
    else if location.protocol is "chrome-extension:"
        log("chrome extension authorize")
        @oauth2_authorize()
    #normal
    else
      Nimbus.Client.GDrive.request_access_token()

  #initialization upon entry to program
  initialize_gdrive: () ->

    log("This part should reflect what initialization needs to be done for GDrive auth")
    # gdrive setup finished
    Nimbus.gdrive_initialized = true
    
    if Nimbus.loaded  # google js load completed
      if location.protocol is "chrome-extension:"
        # the token need be refreshed
        @oauth2_authorize_second_half()
      else
        if Nimbus.Client.GDrive.is_auth_redirected()
          Nimbus.Client.GDrive.handle_auth_redirected()

        console.log "GDrive loaded"
        ### 
          @todo check if token has expired
        ###
        if localStorage['phonegap_token']
          gapi.auth.setToken(JSON.parse(localStorage['phonegap_token']))
          return _this.prepare_gdrive()
        gapi.auth.authorize
          client_id: @key
          scope: @scope
          immediate: true
          authuser : localStorage.authuser || 0
        , (data) =>
          log "client load handled GDrive"
          log data
          
          #only execute anything if auth succeeded, else, just do nothing
          if data isnt null
            @prepare_gdrive()


  #check authorization
  gdrive_authorized: () ->
    return Nimbus.Client.GDrive.check_auth()

  #log out of gdrive
  logout_gdrive: (callback)->
    localStorage.clear()
    gapi.auth.setToken(null)
    
    #clean all the models
    if Nimbus.dictModel?
      for k, v of Nimbus.dictModel
        v.records = {}
    
    if @sync_services?
      Nimbus.Auth.setup(@sync_services)
    
    callback() if callback?

  prepare_gdrive: ->
    window.binary_ready_callback = ->
      Nimbus.Auth.authorized_callback() if Nimbus.Auth.authorized_callback?
    
    window.startRealtime ()->
      log("CURRENT SYNCING CALLBACK")
      Nimbus.Auth.app_ready_func()
      Nimbus.track.google.registered_user()

      setInterval(()->
        #console.log("!!!!!!!!!!!!!!checking~!!!!!!!")
        is_token_there = (gapi.auth.getToken()?) and (not gapi.auth.getToken().access_token?)
        is_token_expired = gapi.auth.getToken().expires_at - (new Date()).getTime()/1000  < 60*10
        if is_token_there or is_token_expired
          return gapi.auth.authorize(
            client_id: Nimbus.Auth.key
            scope: Nimbus.Auth.scope
            immediate: true
            authuser : localStorage.authuser || 0
          ,(data)->
            console.log 'token refreshed'
          )
        return  null 
      ,60000)
    
    ###
    window.current_syncing = new DelayedOp =>
      log("CURRENT SYNCING CALLBACK")
      Nimbus.Auth.app_ready_func()
    ###
    
    #window.handle_initialization.execute_callback() if window.handle_initialization?
    #window.current_syncing.ready()


  # for google chrome extension
  oauth2_authorize: () ->
    background = chrome.extension.getBackgroundPage()

    background.NimbusAuth2 = ((background_window) ->
      # all this must be running in the context of background page

      NimbusAuth2 =
        OAUTH2_REDIRECT_URI: 'http://www.google.com/robots.txt'

        getExtensionId: ->
            background_window.chrome.i18n.getMessage("@@extension_id")

        isOauth2AuthorizeRedirected: (base, state) ->
          if base is  @OAUTH2_REDIRECT_URI and state is @getExtensionId()
            return true
          return false

        parseParamsString: (queryString) ->
          params = {}
          regex = /([^&=]+)=([^&]*)/g

          while m = regex.exec(queryString)
            params[background_window.decodeURIComponent(m[1])] = background_window.decodeURIComponent(m[2])
          params

        parseRedirectedURL: (url) ->
          [base_url, hash] = url.split('#')
          params = @parseParamsString(hash)
          return {base_url, params}

        generateRedirectListener: ->
          listener = (tab_id, change_info, tab) =>
            # only run this when google/robot is opened in tab
            if change_info.status isnt 'loading'
              return
            url_obj = @parseRedirectedURL(tab.url)
            if @isOauth2AuthorizeRedirected(url_obj.base_url, url_obj.params.state)
              # listener finish its duty
              background_window.chrome.tabs.onUpdated.removeListener(listener)
              background_window.chrome.tabs.remove(tab_id)
              url_obj['saved_time'] = (new background_window.Date()).getTime()
              background_window.localStorage['_nimbusGDriveAuthObj'] = background_window.JSON.stringify(url_obj)
              if @isPackagedApp()
                background_window.console.log("in packaged app")
                entension_windows = background_window.chrome.extension.getViews({type: 'tab'})
                for w in entension_windows
                  if w.Nimbus.Auth.GDrive.oauth_status_flag == 'ongoing'
                    w.Nimbus.Auth.GDrive.oauth2_authorize_second_half()

              else if @isBrowserAction()
                background_window.console.log("in browser action")
              return null

          return listener

        installRedirectedListener: ->
          background_window.chrome.tabs.onUpdated.addListener(@generateRedirectListener())

        isBrowserAction: ->
          return 'browser_action' of background_window.chrome.runtime.getManifest()

        isPackagedApp: ->
          return 'app' of background_window.chrome.runtime.getManifest()


      return NimbusAuth2
    )(background)

    Nimbus.Auth.GDrive.oauth_status_flag = 'ongoing'
    # ok, finally install this listener
    background.NimbusAuth2.installRedirectedListener()
    # and open the authorize tab
    url = "https://accounts.google.com/o/oauth2/auth?"
    params =
      client_id: @key
      scope: @scope
      redirect_uri: @OAUTH2_REDIRECT_URI
      state: @getExtensionId()
      response_type: 'token'
      approval_prompt: 'auto'

    url += @buildParamsString(params)
    chrome.tabs.create({url: url})

  oauth2_authorize_second_half: ->
    if localStorage._nimbusGDriveAuthObj?
      url_obj = JSON.parse(localStorage['_nimbusGDriveAuthObj'])

      throw new Error("authorization failed with error: #{url_obj.error}") if 'error' of url_obj

      save_token = url_obj.params
      issued_at = Math.round(url_obj.saved_time / 1000)
      save_token.client_id = @key
      save_token.scope = @scope
      save_token.response_type = 'token'
      save_token.issued_at = issued_at.toString()
      save_token.expires_at = (issued_at + parseInt(save_token.expires_in)).toString()
      save_token.state = ''
    
      delete localStorage['_nimbusGDriveAuthObj']
      localStorage['_chromeExtensionAuth2Token'] = JSON.stringify(save_token)
      
    if localStorage['_chromeExtensionAuth2Token']
      token = JSON.parse(localStorage['_chromeExtensionAuth2Token'])
      gapi.auth.setToken(token)
      Nimbus.Auth.GDrive.oauth_status_flag = 'finish'
      @prepare_gdrive()

  #  setAuthorizedCallback: (callback) ->
    #  @oauth2_authorized_callback = callback

  OAUTH2_REDIRECT_URI: 'http://www.google.com/robots.txt'

  getExtensionId: ->
      chrome.i18n.getMessage("@@extension_id")

  buildParamsString: (obj) ->
    params_arr = for k, v of obj
      "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
    params_arr.join("&")

  getLocalOauth2Token: (token) ->
    if Nimbus.Auth.GDrive._cacheToken?
        return Nimbus.Auth.GDrive._cacheToken
    if localStorage._chromeExtensionAuth2Token?
      token = JSON.parse(localStorage._chromeExtensionAuth2Token)
      Nimbus.Auth.GDrive._cacheToken = token
      token
    else
      null

  isTokenExpires: (token) ->
    if token?.expires_at?
      expires_at = parseInt(token.expires_at)
      now = (new Date()).getTime()
      if (expires_at * 1000) > now
        return true
      else
        return false
    return true

