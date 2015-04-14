angular.module "berlingskeBarometerDirective", []
  .directive "berlingskeBarometer", ($rootScope, pollGetter, pollSorter) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/berlingske-barometer/partials/berlingske-barometer.html"
    link: (scope, element, attr) ->
      $rootScope.view = "percent"
      $rootScope.selected = {}
      currentYear = new Date().getFullYear()

      scope.switchView = (view) -> $rootScope.view = view
      scope.showUncertainty = ->
        rects = d3.selectAll ".party-uncertainty"
        hasClass = rects.classed "ng-hide"

        rects.classed "ng-hide", !hasClass

      getLatestPoll = (year) ->
        pollGetter.get(year, "10.xml").then (data) ->
          if data.error
            getLatestPoll currentYear - 1
          else
            $rootScope.selected.one = pollSorter.sort data.json.polls.poll[0]
            $rootScope.selected.one.datetime = new Date $rootScope.selected.one.result.datetime.replace(" ", "T")
            $rootScope.selected.one.name = data.json.institute.name

      pollGetter.get(null, "valgresultater.xml").then (data) ->
        $rootScope.selected.two = pollSorter.sort data.json.poll[0]
        $rootScope.selected.two.datetime = new Date $rootScope.selected.two.result.datetime.replace(" ", "T")
        $rootScope.selected.two.name = $rootScope.selected.two.result.name

      getLatestPoll currentYear
