#this class makes a call back when all the callback is done
#explaination: many things must execute before executing one thing
class DelayedOp
  constructor: (@callback) -> @count = 1
  wait: => @count++
  ok: => @callback() unless --@count
  ready: => @ok()

#this class checks if a call is being made, 
#if it is, it attaches itself as a callback, else, it makes the main call and sets the state for others to wait
#explaination: many things are waiting for one thing to finish executing
class OneOp
  constructor: () -> 
    @running = false
    @callbacks = []
  add_call: (callback) => 
    @running = true
    @callbacks.push(callback)    
  add_last_call: (callback) =>
    @last_callback = callback
  execute_callback: () =>
    for func in @callbacks
      func()
    @callbacks = []
    @last_callback() if @last_callback?
    @running = false

class DelayedSyncAnimation
  constructor: () -> @count = 1
  wait: =>
    #$("#syncbutton")[0].src="images/ajax-loader.gif"
    @count++
  ok: =>
    unless --@count
      log("ok executed")
      #$("#syncbutton")[0].src="images/02-redo@2x.png"
  ready: => @ok()

exports = this
exports.DelayedOp = DelayedOp
exports.OneOp = OneOp
exports.DelayedSyncAnimation = DelayedSyncAnimation


#this should be moved, a print function that only prints if it's in debug mode
window.debug = false
window.log = ( stuff... ) ->
  if window.debug
    console.log(stuff)
    