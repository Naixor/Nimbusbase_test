app = angular.module 'Realtime', []

app.controller 'realtimeController', ($scope) ->
	Docs = {}

	edit1 = document.getElementById('editer1')
	edit2 = document.getElementById('editer2')

	window.wTodos = TodoModel = {}
	window.debug = false
	$scope.authorized = false
	$scope.shared = false
	$scope.isLoaded = false
	$scope.Todos = []
	$scope.Todos2 = []

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
		,window.c_file.id 

	$scope.add = ->
		TodoModel.create {"title": (new Date()).toString()}, (model)->
			console.log "callback create:", model
			$scope.Todos.push model

	$scope.save = (todo) ->
		t = TodoModel.find todo.id
		t.title = document.getElementById('editer1').value
		
		t.save (newRecord)->
			console.log "callback newRecord:", newRecord

	appReady = ->
		if Nimbus.Auth.authorized
			# window.showChangeText = edit2
			# $scope.authorized = true

			# $scope.realtimeData = window.todo.get "text"
			# Nimbus.Model.Realtime.set_objectchanged_callback (e)->
			# 	console.log "changed!"
			# 	# gapi.drive.realtime.load(c_file.id, fileLoaded, initModel, handleErrors)
			# 	edit2.value = window.todo.get "text"

			# Nimbus.Client.GDrive.get_shared_users_real (users) ->
			# 	console.log users
			# 	$scope.users = []
			# 	for user in users 
			# 		$scope.users.push user
			# 	$scope.$apply()

			# Nimbus.Client.GDrive.getFile c_file.id, (para) ->
			# 	Nimbus.Client.GDrive.readFile para.selfLink, (readFile) ->
			# 		window.readFile = readFile

			# window.startRealtime ->
			# 	$scope.isLoaded = true
			window.wTodoModel = TodoModel = Nimbus.Model.setup "Todos", ["title"]

			

			TodoModel.sync_all ->
				for t in TodoModel.all()
					$scope.Todos.push t

				TodoModel.set_objectchanged_callback (currentEvent, Obj, serverevent)->
					console.log "currentEvent:#{currentEvent}"
					console.log "Obj:#{Obj}"
					console.log "serverevent:#{serverevent}"
					document.getElementById('editer2').value = Obj

				window.startRealtime ->
					console.log "RealTimeStart!"

				$scope.$apply()


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




