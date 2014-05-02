todoApp = angular.module 'todoApp', []	

String::trim = ->
	this.replace "/(^\s*)|(\s$)/g", ""	

Array::deepCopy = (arr) ->
	newArr = []
	for data in arr
		newArr.push data
	newArr 	

todoApp.controller 'todoListController', ($scope) ->
	Todos = {}
	$scope.todos = []
	$scope.AllComleted = "Completed"
	$scope.newTodo = ""
	nowEdit = 
		"title": ""
		"index": -1

	$scope.totalNotComleted = 0
	$scope.totalComleted = 0

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
		 			if data.completed
		 				$scope.totalComleted++
		 			else 
		 				$scope.totalNotComleted++
		 		$scope.$apply()

	Nimbus.Auth.app_ready_func = init

	# $scope.$watch("$scope.dotos", (new, old) -> console.log ,seriftrue);
	completedThings = (com) ->
		if com 
			$scope.totalComleted++
			$scope.totalNotComleted--
		else
			$scope.totalComleted--
			$scope.totalNotComleted++

	$scope.addNewTodo = ->
		$scope.newTodo = $scope.newTodo.trim()
		if $scope.newTodo.length
			# alert $scope.newTodo
			$scope.todos.push Todos.create {"title": $scope.newTodo, "completed": false}
			$scope.newTodo = ""
			$scope.totalNotComleted++

	$scope.changeCompleted = (todo) ->
		todoc = Todos.find todo.id
		if todo.completed
			todoc.completed = false
			todo.completed = false
		else 
			todo.completed = true
			todoc.completed = true
		todoc.save()
		completedThings(todo.completed)

	$scope.removeTodo = (todo, index) ->
		if todo.completed 
			$scope.totalComleted--
		else
			$scope.totalNotComleted--
		(Todos.find todo.id).destroy()

		$('#list li').eq(index).animate {"-webkit-transform": "translateX(-1em)", "opacity": "0.0"}, 400, ->
			$scope.todos.splice ($scope.todos.indexOf todo),1
			$scope.$apply()
	
		return

	$scope.editTodo = (index) ->
		label = '#label'+index
		$(label).removeAttr "disabled"
		$(label).focus()
		nowEdit.index = index

	$scope.doneEditTitle = (todo) ->
		nowEdit.title = $scope.todos[nowEdit.index].title.trim()
		console.log nowEdit.title
		todot = Todos.find todo.id
		if nowEdit.title.length
			todot.title = nowEdit.title
			todot.save()
		else
			$scope.removeTodo todo
		label = '#label'+nowEdit.index
		$(label).attr "disabled", "disabled"
		nowEdit = 
			"title": ""
			"index": -1

	$scope.disFilter = ->
		$scope.todos = []
		for data in Todos.all()
			$scope.todos.push data
		$scope.$apply()		

	$scope.filterNotCompleted = ->
		$scope.todos = []
		for data in Todos.findAllByAttribute "completed", false
			$scope.todos.push data
		$scope.$apply()

	$scope.filterCompleted = ->
		$scope.todos = []
		for data in Todos.findAllByAttribute "completed", true
			$scope.todos.push data
		$scope.$apply()

	$scope.MarkAll = (mark) ->
		$scope.disFilter()
		switch mark
			when "Completed"
				$scope.AllComleted = "NotCompleted"
				Todos.each (data) ->
					data.updateAttribute "completed", true
				for t in $scope.todos
					t.completed = true
				$scope.totalComleted = $scope.todos.length
				$scope.totalNotComleted = 0
			when "NotCompleted"
				$scope.AllComleted = "Completed"
				Todos.each (data) ->
					data.updateAttribute "completed", false
				for t in $scope.todos
					t.completed = false
				$scope.totalNotComleted = $scope.todos.length
				$scope.totalComleted = 0

	$scope.logout = -> 
		Nimbus.Auth.logout()
		window.location.reload()



	