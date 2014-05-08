Nimbus.Model.LocalSync = 

  classname: "Nimbus.Model.LocalSync"

  extended: ->
    @sync @proxy(@saveLocal)
    @fetch @proxy(@loadLocal)
  
  saveLocal: ->
    result = JSON.stringify(this)
    localStorage[@name] = result
  
  loadLocal: (callback)->
    result = localStorage[@name]
    return  unless result
    result = JSON.parse(result)
    @refresh result
    
    callback() if callback?
