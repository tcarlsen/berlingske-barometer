angular.module "totalChartDirective", []
  .directive "totalChart", ($window) ->
    restrict: "E"
    scope:
      data: "="
      view: "="
    link: (scope, element, attrs) ->
      firstRun = true
      svgPadding =
        top: 60
        right: 0
        bottom: 35
        left: 0
      svgHeight = 300

      baseSvg = d3.select(element[0]).append "svg"
        .attr "width", "100%"
        .attr "height", svgHeight + svgPadding.top + svgPadding.bottom

      $window.onresize = -> scope.$apply()

      scope.$watch (->
        angular.element($window)[0].innerWidth
      ), ->
        return if firstRun

        firstRun = true
        baseSvg.selectAll("*").remove()
        render scope.data, scope.view

      scope.$watch "data", ((newData, oldData) ->
        return if angular.equals(newData, oldData)

        render newData, scope.view
      ), true

      scope.$watch "view", ((newView, oldView) ->
        return if angular.equals(newView, oldView)

        firstRun = true
        baseSvg.selectAll("*").remove()
        render scope.data, newView
      ), true

      render = (data, view) ->
        renderColumnView(data) if view is "percent"
        renderPieView(data)  if view is "mandates"

      renderColumnView = (data) ->
        return if !data.one or !data.two

        if firstRun
          svg = baseSvg.append("g").attr "transform", "translate(#{svgPadding.left}, #{svgPadding.top})"
        else
          svg = baseSvg

        svgWidth = d3.select(element[0])[0][0].offsetWidth
        svgSpaces = svgWidth / (data.one.totals.length + data.two.totals.length)
        columnWidth =  svgSpaces * 0.9
        compareMargin = 5
        columnMargin = svgWidth - (columnWidth * 2) - svgPadding.left - svgPadding.right - compareMargin
        maxPercentOne = d3.max(data.one.totals, (d) -> parseFloat d.percent)
        maxPercentTwo = d3.max(data.two.totals, (d) -> parseFloat d.percent)
        maxPercent = d3.max([maxPercentOne, maxPercentTwo])
        yScale = d3.scale.linear()
          .domain [0, maxPercent]
          .range [svgHeight, 0]

        pollOne = svg.selectAll(".poll-one.column").data(data.one.totals)

        pollOne
          .enter()
            .append "rect"
              .attr "class", "poll-one column"
              .attr "height", 0
              .attr "y", svgHeight
              .attr "fill", (d) -> d.color.first

        pollOne
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnWidth) + (svgPadding.left / 2) + (compareMargin * i)
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale(d.percent)
            .attr "y", (d) -> yScale d.percent

        pollTwo = svg.selectAll(".poll-two.column").data(data.two.totals)

        pollTwo
          .enter()
            .append "rect"
              .attr "class", "poll-two column"
              .attr "height", 0
              .attr "y", svgHeight
              .attr "fill", (d) -> d.color.second

        pollTwo
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnWidth) + (svgPadding.left / 2) + (compareMargin * i) + columnMargin
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale(d.percent)
            .attr "y", (d) -> yScale d.percent

        pollOnePercent = svg.selectAll(".poll-one.block-percent").data(data.one.totals)

        pollOnePercent
          .enter()
            .append "text"
            .attr "class", "poll-one block-percent"
            .attr "text-anchor", "middle"
            .attr "y", (d) -> svgHeight

        pollOnePercent
          .text (d) -> (Math.round(d.percent * 10 ) / 10).toString().replace(".", ",")
          .attr "x", (d, i) -> ((i * columnWidth) + (svgPadding.left / 2)) + (columnWidth / 2) + (compareMargin * i)
          .transition().duration(1000)
            .attr "y", (d) -> yScale(d.percent) - 7

        pollTwoPercent = svg.selectAll(".poll-two.block-percent").data(data.two.totals)

        pollTwoPercent
          .enter()
            .append "text"
              .attr "class", "poll-two block-percent"
              .attr "text-anchor", "middle"
              .attr "y", (d) -> svgHeight

        pollTwoPercent
          .text (d) -> (Math.round(d.percent * 10 ) / 10).toString().replace(".", ",")
          .attr "x", (d, i) -> ((i * columnWidth) + (svgPadding.left / 2)) + (columnWidth / 2) + (compareMargin * i) + columnMargin
          .transition().duration(1000)
            .attr "y", (d) -> yScale(d.percent) - 7

        pollOneLetters = svg.selectAll(".poll-one.block-letters").data(data.one.totals)

        pollOneLetters
          .enter()
            .append "text"
              .attr "class", "poll-one block-letters"
              .attr "text-anchor", "start"
              .attr "transform", "rotate(-90)"
              .attr "x", -svgHeight + 14

        pollOneLetters
          .text (d) -> d.letters
          .attr "y", (d, i) -> (((i * columnWidth) + (svgPadding.left / 2)) + (columnWidth / 2)) + (compareMargin * i) + 5

        pollTwoLetters = svg.selectAll(".poll-two.block-letters").data(data.two.totals)

        pollTwoLetters
          .enter()
            .append "text"
              .attr "class", "poll-two block-letters"
              .attr "text-anchor", "start"
              .attr "transform", "rotate(-90)"
              .attr "x", -svgHeight + 14

        pollTwoLetters
          .text (d) -> d.letters
          .attr "y", (d, i) -> (((i * columnWidth) + (svgPadding.left / 2)) + (columnWidth / 2)) + (compareMargin * i) + columnMargin + 5

        firstRun = false

      renderPieView = (data) ->
        return if !data.one or !data.two

        pi = Math.PI
        svgWidth = d3.select(element[0])[0][0].offsetWidth
        pieRadius = 110
        pollPie = d3.layout.pie().sort(null).value((d) -> return d.mandates).startAngle(-90 * (pi / 180)).endAngle(90 * (pi / 180))

        if svgWidth is 220
          pollOneTopMargin = svgHeight - 100
          pollTwoTopMargin = svgHeight + pieRadius
          pollOneLeftMargin = pieRadius
          pollTwoLeftMargin = pieRadius
        else
          if svgWidth > 350
            if svgWidth < (pieRadius * 5)
              pieRadius = svgWidth / 5

            pollOneTopMargin = pieRadius + 20
            pollTwoTopMargin = pollOneTopMargin
            pollOneLeftMargin = pieRadius + 30
            pollTwoLeftMargin = svgWidth - pieRadius - 30
          else
            if svgWidth < (pieRadius * 2)
              pieRadius = svgWidth / 2

            pollOneTopMargin = pieRadius + 20
            pollTwoTopMargin = pollOneTopMargin + pieRadius + 20
            pollOneLeftMargin = svgWidth / 2
            pollTwoLeftMargin = pollOneLeftMargin

        if firstRun
          pollOne = baseSvg.append("g").attr("id", "pollOneTotal").data([data.one.totals]).attr "transform", "translate(#{pollOneLeftMargin}, #{pollOneTopMargin})"
          pollTwo = baseSvg.append("g").attr("id", "pollTwoTotal").data([data.two.totals]).attr "transform", "translate(#{pollTwoLeftMargin}, #{pollTwoTopMargin})"
        else
          pollOne = d3.select("#pollOneTotal").data([data.one.totals])
          pollTwo = d3.select("#pollTwoTotal").data([data.two.totals])

        pollArc = d3.svg.arc().outerRadius(pieRadius)

        pollOneSlices = pollOne.selectAll(".poll-one.slice").data(pollPie)

        pollOneSlices
          .enter()
            .append "path"
              .attr "class", "poll-one slice"
              .attr "fill", (d) ->  d.data.color.first

        pollOneSlices
          .transition().duration(1000)
            .attr "d", pollArc

        pollOneTexts = pollOne.selectAll(".poll-one.texts").data(pollPie)

        pollOneTexts
          .enter()
            .append "text"
              .attr "class", "poll-one texts"
              .attr "text-anchor", "middle"
              .attr "fill", "#fff"
              .attr "y", -35
              .attr "x", (d, i) ->
                if i is 0
                  return -40
                else
                  return 40

        pollOneTexts
          .text (d) -> d.data.mandates

        pollTwoSlices = pollTwo.selectAll(".poll-two.slice").data(pollPie)

        pollTwoSlices
          .enter()
            .append "path"
              .attr "class", "poll-two slice"
              .attr "fill", (d) -> d.data.color.second
        pollTwoSlices
          .transition().duration(1000)
            .attr "d", pollArc

        pollTwoTexts = pollTwo.selectAll(".poll-two.texts").data(pollPie)

        pollTwoTexts
          .enter()
            .append "text"
              .attr "class", "poll-two texts"
              .attr "text-anchor", "middle"
              .attr "fill", "#fff"
              .attr "y", -35
              .attr "x", (d, i) ->
                if i is 0
                  return -40
                else
                  return 40

        pollTwoTexts
          .text (d) -> d.data.mandates

        firstRun = false
