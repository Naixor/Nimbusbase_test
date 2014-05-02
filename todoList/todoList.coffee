todoApp = angular.module 'todoApp', []		 	

todoApp.controller 'todoListController', ($scope) ->
	Todos = []
	$scope.todos = []
	$scope.newTodo = ""

	init = () ->
		if Nimbus.Auth.authorized()
		 	$('#loginView').animate 
		 		'opacity': '0.0'
		 		1000
		 		'linear' 
		 		->	
		 			$('#loginView').css {'display': 'none'}
		 			$('#todoListView').css({'display': 'block'}).animate {'opacity': '1.0', 'display': 'block'}, 500, 'linear'

		 	Todos = Nimbus.Model.setup 'Todos', ['title', 'completed']
		 	Todos.sync_all ->
		 		datas = Todos.all()
		 		for data in datas
		 			$scope.todos.push data
		 		$scope.$apply()

	Nimbus.Auth.app_ready_func = init

	$scope.addNewTodo = () ->
		$scope.newTodo = $scope.newTodo.replace "/(^\s*)|(\s$)/g", ""
		if $scope.newTodo.length
			alert $scope.newTodo
			$scope.todos.push Todos.create {"title": $scope.newTodo, "completed": false}
			$scope.newTodo = ""


	$scope.logout = () -> 
		Nimbus.Auth.logout()
		window.location.reload()



	