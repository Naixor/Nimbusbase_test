app = angular.module 'Realtime', []

app.controller 'realtimeController', ($scope) ->
	Docs = {}

	edit1 = document.getElementById('editer1')
	edit2 = document.getElementById('editer2')

	$scope.realtimeData = "Loading..."
	$scope.authorized = false
	$scope.shared = false
	$scope.isLoaded = false
	$scope.realtimefile = {}

	$scope.authorize = ->
		objAuth = 
		"GDrive":
      		"key": "460727743836-sd4rpc7j65lr827sc5dokmmndhqhi48q.apps.googleusercontent.com"
      		"scope": "https://www.googleapis.com/auth/drive"
      		"app_name": "gdrive_realtime_test"
    	"Dropbox":
      		"key": ""
      		"secret": ""
      		"app_name": ""
    	"synchronous": true
		Nimbus.Auth.setup objAuth
		Nimbus.Auth.authorize 'GDrive'
		Nimbus.Auth.authrized_callback = ->
			console.log "Authorized sucess!"

	$scope.shareClient = ->
		window.create_share_client()

	appReady = ->
		if Nimbus.Client.GDrive.check_auth
			$scope.authorized = true
			# console.log "todo:#{window.todo}"
			console.log "c_file.id:#{window.c_file.id}"
			$scope.realtimeData = window.todo.get "text"
			Nimbus.Model.Realtime.set_objectchanged_callback (e)->
				console.log "changed!"
				edit2.value = window.todo.get "text"

			edit1.onkeyup = (e)->
				window.todo.set "text", edit1.value

			window.startRealtime ->
				$scope.isLoaded = true

		else
			alert "You have not authorize!"
			$scope.authorized = false


	Nimbus.Auth.set_app_ready appReady

window.loadFunc = ->
	objAuth = 
		"GDrive":
      		"key": "460727743836-sd4rpc7j65lr827sc5dokmmndhqhi48q.apps.googleusercontent.com"
      		"scope": "https://www.googleapis.com/auth/drive"
      		"app_name": "gdrive_realtime_test"
    	"Dropbox":
      		"key": ""
      		"secret": ""
      		"app_name": ""
    	"synchronous": true
	Nimbus.Auth.setup objAuth
	Nimbus.Auth.authorize 'GDrive'
	Nimbus.Auth.authrized_callback = ->
		console.log "Authorized sucess!"


