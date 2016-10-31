//contents = ['A','B'] 
contents = [article1,article2];
//titles = [title1,title2]

var app = angular.module('NerApp',[]);

app.controller('BodyCtrl', ['$scope', '$http', function($scope, $http){

  $scope.contents = contents;
  $scope.companies = []
  //$scope.titles = titles;

  $scope.edit = function(){
  	//console.log($scope.contents[$scope.articleNum])
  	$scope.textValue = $scope.contents[$scope.articleNum];
  }

  $scope.$watch('textValue', function(newValue, oldValue) {
  	if(!newValue) return;

  	console.log(newValue);

  	var req = {
  				method: 'POST',
  				url: 'http://ec2-35-162-101-49.us-west-2.compute.amazonaws.com:8080/ner',
  				headers: {
  					'Content-Type': undefined
  				},
  				data: { content: newValue }
  	};

    /* Sending request for headlines */
  	$http(req).then(function(response){
  		$scope.companies = response.data;
  	})

  });


}]);