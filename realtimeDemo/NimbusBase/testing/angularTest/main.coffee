 

#Model
window.Post =  Nimbus.Model.setup("Post", ["title", "link", "category","create_time"])
 
# angular  code
#############
window.main=angular.module("main",[])
.controller("mainCtl", ($scope)->
	$scope.watchObject = Post.create({"title": "123","link":"http://www.baidu.com"})
	$scope.$watch("watchObject", (n,v)->
		console.log(JSON.stringify(n))
	)

)


 