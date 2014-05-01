todoApp = angular.module 'todoApp', []	

todoApp.factory 'isAuthorized', ->
	if window.todoList? and window.todoList isnt "undefined"
		todoList = window.todoList
		show = todoList.authorized()
	else 
		show = false
	alert "isAuthorized:"+show
	show

todoApp.controller 'LoginController', ($scope, isAuthorized) ->
	$scope.show = isAuthorized
		
	$scope.loginAction = (model) -> 
		todoList = window.todoList
		switch model
			when "Dropbox" then todoList.authorize 'Dropbox'
			when "GDrive" then todoList.authorize 'GDrive'
			else console.error "loginAction request either Dropbox or GDrive only"
		todoList.authorized_callback ->
			console.log "authorized!" 

	watchFn = () ->
		if $scope.show
		 	$('#loginView').animate 
		 		'opacity': '0.0'
		 		500
		 		'linear' 
		 		->	
		 			$('#loginView').css {'display': 'none'}
		 			$('#todoListView').css({'display': 'block'}).animate {'opacity': '1.0', 'display': 'block'}, 500, 'linear'
		 	console.log "changed"

	$scope.$watch '$scope.show', watchFn, true
	 	

todoApp.controller 'todoListViewController', ($scope) ->
	$scope.logout = () -> 
		window.todoList.logout()



	