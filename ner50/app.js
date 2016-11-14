var sample_title = 'Coal producers are pressing the UK government to rethink its decision to scrap a £1bn scheme to develop carbon capture and storage technology.';
var sample_content = '<p>Coal producers are pressing the UK government to rethink its decision to scrap a £1bn scheme to develop carbon capture and storage technology. The World Coal Association, which represents big miners such as <code>Glencore</code> and <code>Anglo American</code>, has written to Greg Clark, the new business secretary, appealing for support for carbon capture.</p><p>Carbon capture technology, which involves capturing emissions from coal and gas power stations before they enter the atmosphere, has been suggested for years as a way to tackle climate change while still burning fossil fuels. Its prospects for adoption in the UK had a setback last year when George Osborne, then chancellor, cancelled a competition in which two carbon capture projects were vying for government backing.</p><p>The coal industry sees the recent change of leadership in Downing Street and the Treasury, as well as the merging of the energy and business departments, as a chance to put carbon capture back on the agenda.</p><p>“With a fresh pair of eyes in government, there is an opportunity for the UK to take another look at the issue,” said Benjamin Sporton, chief executive of the industry group.</p><p>In his letter to Mr Clark, seen by the Financial Times, Mr Sporton wrote that carbon capture was of “critical importance” to the UK’s chances of meeting its CO2 reduction targets and described the withdrawal of government support as “highly regrettable”.</p><p>The intervention comes at a time of upheaval in UK energy policy after the folding of the <code>Department of Energy and Climate Change</code> into a new Department for Business, Energy & Industrial Strategy under Mr Clark.Last month’s decision by Theresa May, prime minister, to put on hold the proposed £18bn Hinkley Point nuclear power station in the West Country pending a review has deepened the sense of uncertainty.</p><p>Coal producers hope that greater integration between energy and industrial policy will work in their favour if they can make the case for carbon capture as a way to cut greenhouse gases while maintaining plentiful supplies of affordable electricity. Mr Sporton’s letter says the technology could enable “continued use of coal for electricity in the UK beyond 2025”, referring to the government deadline for removing coal from the country’s energy mix.</p><p>A business department official said carbon capture “has still got a role to play in the long-term decarbonisation of the UK” and that the government would “continue to work with the industry”.</p><p>Advocates say the UK is ideally placed for the technology because captured CO2 can be injected into depleted North Sea oil and gasfields and stored indefinitely. The first commercial scale coal-fired power station fitted with carbon capture equipment began operating in Canada in 2014. Projects led by Royal Dutch Shell in Scotland and Drax in Yorkshire were competing to pioneer the technology in Britain until the government pulled the plug.</p><p>However, Mr Sporton said carbon capture remained crucial to curbing global emissions, given rising use of coal and gas in developing economies such as China and India. There could be a big export opportunity for the UK if the government promoted the technology, he added.</p><p>The Treasury’s ditching of the carbon capture competition was attributed to high costs, but a report by the National Audit Office last month warned that the absence of the technology, or its delayed introduction, might lead to greater expense for the UK in the long run.</p><p>The Treasury estimated the technology would require a subsidised electricity price of £170 per megawatt hour. This compared with £92.50 for nuclear power from Hinkley Point.</p><p>However, advocates say the cost will come down as the technology matures. They argue that growing use of gas in the UK will make carbon capture essential to hit climate targets — and that the cost of the technology will keep rising the longer it is delayed.</p>';
var sample_company = [{symbol:'HSBC'}, {symbol:'MKS'}, {symbol:'JPM'}];

var app = angular.module('app', ['ngTouch', 'ui.router', 'ngAnimate']);

var server_url = 'http://ec2-35-162-101-49.us-west-2.compute.amazonaws.com:8000';

app.controller('BodyCtrl', ['$rootScope', '$scope', '$state', '$http', '$element','$location' , '$timeout','$q', function($rootScope, $scope, $state, $http, $element, $location, $timeout, $q) { 
  
  $scope.headlineScroll = 0;
  $scope.blockSearch = false;
  $scope.selectedKeyword = 0;

  var open_func = function() {
    //console.log('Request for id='+this.id)
          
    $state.go('full', {
      id: this.id, 
      title: this.title,
      content: this.content,
      companies: this.companies,
      matches: this.matches
    });

  };

  $state.go('welcome', {});

  $scope.MakeRequest = function(keywordNum) {

    $scope.selectedKeyword = keywordNum;

    if(keywordNum) {

      //var searchQuery = this.searchTerms;

      $scope.statProgress = 'pending';
      $scope.articles = [];

      /* Go to the state */
      $state.go('headline', {});
      $scope.blockSearch = true;

      /* Reset Scroll so it moves to the top */
      $scope.headlineScroll = 0;
      var main_ele = $element.find('.main');
      main_ele.scrollTop($scope.headlineScroll);          


      

        /* Create request for keywords */
        var getHeadlines = {
          method: 'POST',
          url: server_url+'/articles/headlines',
          headers: {
            'Content-Type': undefined
          },
          data: { keynum: keywordNum }
        }

        /* Sending request for headlines */
        $http(getHeadlines).then(function(response){
          re = /<p>([^<]*)<\/p>/
          articles = $.map( response.data, function(article) {
             firstPar = re.exec(article.content)[0];
             //console.log(firstPar)
             firstPar = firstPar.replace(re,'$1');
             return {
                    id: article.id,
                    title: article.title,
                    content: article.content,
                    paragraphOne : firstPar,
                    open: open_func,
                    matches: null,
                    companies: null,
                    count: 0,
                    ready: false
              }
          });

          $scope.articles = articles;

          function factory(arc) {
            return function() {
              var getFullArticles = {
                method: 'POST',
                url: server_url + '/articles/full',
                headers: {
                  'Content-Type': undefined
                },
                data: { id: arc.id }
              };
              return $http(getFullArticles).then(
                function(response){
                  console.log(arc.id);
                  //console.log(response.data);
                  arc.companies = $.map(response.data, function(obj){
                    return obj.company;
                  });

                  arc.count = arc.companies.length;

                  arc.matches = [];
                  $.each(response.data, function(i, obj){
                    console.log(obj.occurrence);
                    Array.prototype.push.apply(arc.matches, obj.occurrence.search);
                  });

                  arc.ready = true;                              
                  console.log(arc.matches);
                },
                function(response){
                  console.log(response.status);

                });
            };
          }

          var chain = $q.when();
          $scope.articles.forEach(function (article) {
            chain = chain.then(factory(article));
          });

        }, function(response){$scope.blockSearch = false; console.log(response.status);});

        /* Independent request for building co-matrix */
          
        
        /* var createItems = {
          method: 'GET',
          url: server_url + '/comatrix/items-all?query=' + encodeURIComponent(searchQuery)
        };
        var createSymDict = {
          method: 'GET',
          url: server_url + '/comatrix/symdict-all'
        };

        // In deployment mode, I will create two server instance to solve blocking problems!!!!!
        var buildmat = function(){
          $q.when().then(function(result){
            return $http(createItems);
          }, function(reason){
            $scope.blockSearch = false;
          }).then(function(){
            return $http(createSymDict);
          }).then(function(){
            $scope.statProgress = 'finished';
            $scope.blockSearch = false;
          });
        };
        $timeout(buildmat, 1000); */
      
    }
  }

  $rootScope.$on("$locationChangeStart", function(event, next, current){
 
  });

  $rootScope.$on("$locationChangeSuccess", function(){

    if($location.path() == '/headline') {
      console.log('/headline');
      var main_ele = $element.find('.main');
      main_ele.scrollTop($scope.headlineScroll);
      angular.element(main_ele).bind("scroll", function(){
        $scope.headlineScroll = this.scrollTop;
      });
    } else if($location.path() == '/full') {
      console.log('/full');
      //$element[0].scrollTop = $scope.viewOnePreviousScroll;
    }
  });

}]);

/* UI-Route */

app.config(function($stateProvider, $urlRouterProvider) {
  $stateProvider
    .state('welcome', {
      url: '/welcome',
      views: {
        root:{
          templateUrl: 'root.html' 
        },
        'panel@welcome':{
          template: '<div class="waiting-text" ng-if="searchTerms">Press <em>Enter</em> to proceed.</div>'
        }
      }
    })
    .state('headline', {
      url: '/headline',
      params: {
        articles: null
      },
      views: {
        root:{
          templateUrl: 'root.html' 
        },
        'main@headline':{
          templateUrl: 'headlines.html',
          controller: function($scope, $timeout) {

          }
        },
        'panel@headline':{
          templateUrl: 'stat.html'
        }
      }     
    })
    .state('full', {
      url: '/full',
      params: {
            id: null,
            title: null,
            content: null,
            companies: null,
            matches: null
        },
      views: {
        root:{
          templateUrl: 'root.html' 
        },
        'main@full':{
          templateUrl: 'fullarticle.html',
          controller: function ($scope, $stateParams, $sce) {
            $scope.id = $stateParams.id;
            $scope.title = $stateParams.title;
            if($stateParams.matches.length > 0) {
              var content = $stateParams.content.replace(RegExp('('+$stateParams.matches.join('|')+')','g'),'<code>$1</code>');
              $scope.content = $sce.trustAsHtml(content);
            } else {
              $scope.content = $sce.trustAsHtml($stateParams.content);
            }
          }
        },
        'panel@full':{
          templateUrl: 'tickerlist.html',
          controller: function ($scope, $stateParams) {
              $scope.companies = $stateParams.companies 
            }
        }
      }
    });
  $urlRouterProvider.otherwise('/welcome');
});






