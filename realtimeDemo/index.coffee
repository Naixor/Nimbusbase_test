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
	$scope.femail = ""
	$scope.users = []

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
		Nimbus.Client.GDrive.add_share_user_real $scope.femail, ->
			console.log "add real share:#{$scope.femail}"
		window.c_file.id 

	$scope.getShareUser = ->
		Nimbus.Client.GDrive.get_shared_users_real (users) ->
			console.log users
			for user in users 
				$scope.users.push user
			$scope.$apply()

	fileLoaded = (doc) ->
		string = doc.getModel().getRoot().get 'todo'
		edit2.value = string.get "text"
		gapi.drive.realtime.databinding.bindString string.get "text", edit2

	appReady = ->
		if Nimbus.Client.GDrive.check_auth
			window.showChangeText = edit2
			$scope.authorized = true
			# console.log "todo:#{window.todo}"
			console.log "c_file.id:#{window.c_file.id}"
			$scope.realtimeData = window.todo.get "text"
			Nimbus.Model.Realtime.set_objectchanged_callback (e)->
				console.log "changed!"
				# gapi.drive.realtime.load(c_file.id, fileLoaded, initModel, handleErrors)
				edit2.value = window.todo.get "text"

			Nimbus.Client.GDrive.get_shared_users_real (users) ->
				console.log users
				$scope.users = []
				for user in users 
					$scope.users.push user
				$scope.$apply()

			Nimbus.Client.GDrive.getFile c_file.id, (para) ->
				Nimbus.Client.GDrive.readFile para.selfLink, (readFile) ->
					window.readFile = readFile

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



