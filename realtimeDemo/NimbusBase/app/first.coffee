#this script has the stuff that should be called before anything else

#handling GDrive intiialization setup
(->
  if not window.Nimbus?
    window.Nimbus = {}
  Nimbus = window.Nimbus

  window.handle_initialization = null
  Nimbus.loaded = false
  window.handleClientLoad = ->
    console.log "loaded CALLED"
    Nimbus.loaded = true
    Nimbus.Auth.initialize()  if Nimbus.gdrive_initialized

  #put in the GDrive script
  headID = document.getElementsByTagName("head")[0]
  newScript = document.createElement("script")
  newScript.type = "text/javascript"
  newScript.src = "https://apis.google.com/js/client.js?onload=handleClientLoad"
  headID.appendChild newScript
)()
