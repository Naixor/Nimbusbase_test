mixpanel_token = "57da9d172e8c2000bca77d9ebb935752"

Nimbus.track =
  
  #send people request
  #input: a json to send to the people engage api
  #output: the json should be sent to the api
  send_people_request: (x) ->
    xhr = new XMLHttpRequest()
    
    log(JSON.stringify(x))
    encoded = Base64.encode(JSON.stringify(x))
    
    window.data = "data=#{ encoded }"
    
    xhr.open("POST", "http://api.mixpanel.com/engage")
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded")
    xhr.onreadystatechange = (status, response) =>
      
      if xhr.readyState is 4
        try
          log("xhr", xhr)
          log("mixpanel response done")
          log("response: ", xhr.response)
    
    xhr.send(data)
    window.xhr = xhr    
  
  #registered a user after login
  registered_user: ()->
    log("registered user")
    
    if Nimbus.Auth.service is "Dropbox"
      Nimbus.Client.Dropbox.getAccountInfo (info)->
        
        n = info.display_name
        [first, last] = n.split(" ")
        email = ""
        email = info.email if info.email?
        
        x =
          $set:
            $first_name: first
            $last_name: last
            $app: Nimbus.Auth.app_name
            $service: Nimbus.Auth.service
            $email: email
            $url: window.location.href
          
          $token: mixpanel_token
          $distinct_id: email
        
        log(x)
        Nimbus.track.send_people_request(x)
        
    if Nimbus.Auth.service is "GDrive"
      email = Nimbus.Client.GDrive.get_user_email()
      
      Nimbus.Client.GDrive.get_current_user (info)->
        
        n = info.name
        [first, last] = n.split(" ")        
        
        x =
          $set:
            $first_name: first
            $last_name: last
            $app: Nimbus.Auth.app_name
            $service: Nimbus.Auth.service
            $email: email
            $url: window.location.href
          
          $token: mixpanel_token
          $distinct_id: email
        
        log(x)
        Nimbus.track.send_people_request(x)        
      

  #report storage stat, should only do once a day
  report_storage_stat: ()->
    log("report storage stat")
    
    now = new Date()
    
    last_reported_date = localStorage["last_reported_date"] if localStorage["last_reported_date"]?
    
    if last_reported_date 
      if now - last_reported_date > 86400000 #single day
        log("start sending data")
      localStorage["last_reported_date"] = now
    else
      log("start sending data")  

this.Nimbus = Nimbus