angular.module "pollMenuDirective", []
  .directive "pollMenu", ($rootScope, $document, $filter, pollGetter, pollSorter) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/berlingske-barometer/partials/poll-menu.html"
    link: (scope, element, attr) ->
      currentYear = new Date().getFullYear()
      activeYear = currentYear
      startTop = 0
      startLeft = 0
      top = 0
      left = 0

      drag = (event) ->
        event.preventDefault()

        startTop = event.pageY - top
        startLeft = event.pageX - left

        $document.on "mousemove", mousemove
        $document.on "touchmove", mousemove
        $document.on "mouseup", mouseup
        $document.on "touchend", mouseup

      mousemove = (event) ->
        top = event.pageY - startTop
        left = event.pageX - startLeft

        element.css
          marginLeft: 0
          opacity: 0.7
          MsTransform: "translate3d(#{left}px, #{top}px, 0)"
          MozTransform: "translate3d(#{left}px, #{top}px, 0)"
          WebkitTransform: "translate3d(#{left}px, #{top}px, 0)"
          transform: "translate3d(#{left}px, #{top}px, 0)"

      mouseup = ->
        element.css "opacity", "1"

        $document.off "mousemove", mousemove
        $document.off "touchmove", mousemove
        $document.off "mouseup", mouseup
        $document.off "touchend", mouseup

      getPollDates = ->
        pollGetter.get(activeYear, "#{scope.active_institute}.xml").then (data) ->
          if data.error
            activeYear -= 1
            scope.years = [activeYear..2010]
            getPollDates()
          else
            if data.json.hasOwnProperty "polls"
              scope.pollList = data.json.polls.poll
            else
              scope.pollList = data.json.poll

            console.log scope.pollList

            scope.pollList = [scope.pollList] if !scope.pollList.length

      scope.active_poll = "one"
      scope.active_institute = 10
      scope.years = [currentYear..2010]

      scope.choseInstitute = (index, id) ->
        element.find("year-carousel")[0].scrollLeft = 0

        if index is -1
          activeYear = currentYear
          scope.active_institute = id
          scope.years = [currentYear..2010]

          getPollDates()

          return

        institute = scope.institutes[index]

        scope.active_institute = institute.id
        years = []

        if institute.xmls.xml.length is undefined
          years.push institute.xmls.xml.year
        else
          years = (xml.year for xml in institute.xmls.xml)

        scope.years = years.reverse()
        activeYear = scope.years[0]

        getPollDates()

      scope.setNewPoll = (index) ->
        $rootScope.selected[scope.active_poll] = pollSorter.sort scope.pollList[index]
        $rootScope.selected[scope.active_poll].datetime = new Date $rootScope.selected[scope.active_poll].result.datetime.replace(" ", "T")

        if scope.active_institute is 10
          $rootScope.selected[scope.active_poll].name = "Berlingske Poll of Polls"
        else if scope.active_institute is "all"
          $rootScope.selected[scope.active_poll].name = $rootScope.selected[scope.active_poll].result.name
        else
          for institute in scope.institutes
            $rootScope.selected[scope.active_poll].name = institute.name if institute.id is scope.active_institute

      scope.yearScroll = (direction) ->
        carouselEle = element.find "year-carousel"
        yearEles = carouselEle.find "year"
        currentPosition = carouselEle[0].scrollLeft
        yearWidth = yearEles[0].offsetWidth

        if direction is "left"
          newPosition = currentPosition - yearWidth
          return if newPosition < 0
        else
          newPosition = currentPosition + yearWidth
          return if newPosition > (yearEles.length - 1) * yearWidth

        index = newPosition / yearWidth
        activeYear = carouselEle.find("year")[index].innerHTML

        carouselEle[0].scrollLeft = newPosition
        getPollDates()

      element.find("menu-helper").on "mousedown", drag
      element.find("menu-helper").on "touchstart", drag

      pollGetter.get(null, "overview.xml").then((data) ->
        scope.institutes = $filter('orderBy')(data.json.institute, 'name')
        getPollDates()
      )
