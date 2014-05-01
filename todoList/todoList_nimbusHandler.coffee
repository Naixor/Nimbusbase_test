todoList = () ->
	@authorize = (witch) ->
		sync_obj = 
			"GDrive": 
				"key": "281922744418.apps.googleusercontent.com"
				"scope": "https://www.googleapis.com/auth/drive"
				"app_name": "nimbus_todoList"
			"Dropbox": 
				"key": "abgyfuygy8lh6xw"
				"secret": "kz4dqgty5b2p0km"
				"app_name": "nimbus_todoList"
			"synchronous": true
		Nimbus.Auth.setup sync_obj
		Nimbus.Auth.authorize(witch)
	@authorized = ->
		Nimbus.Auth.authorized()
	@authorized_callback = (callback) ->
		if (typeof callback) == "function"
			Nimbus.Auth.authorized_callback = callback
		else
			console.error "authorized argument request a function" 
	@logout = -> 
		Nimbus.Auth.logout()
		window.location.reload()		
	@release = ->
		if window.todoList? and window.todoList isnt "undefiend"
			window.todoList = null
	return
window.todoList = new todoList()