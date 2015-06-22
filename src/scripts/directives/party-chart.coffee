angular.module "partyChartDirective", []
  .directive "partyChart", ($window) ->
    restrict: "E"
    scope:
      data: "="
      view: "="
    link: (scope, element, attrs) ->
      firstRun = true
      retina = true if $window.devicePixelRatio > 1
      svgPadding =
        top: 60
        right: 25
        bottom: 35
        left: 25
      svgHeight = 300
      partyColors =
        first:
          "Ø": "#731525"
          "Å": "#5AFF5A"
          F: "#9C1D2A"
          A: "#E32F3B"
          B: "#E52B91"
          C: "#0F854B"
          V: "#0F84BB"
          O: "#005078"
          I: "#EF8535"
          K: "#F0AC55"
        second:
          "Ø": "#93494E"
          "Å": "#ACFFAC"
          F: "#B04B53"
          A: "#E54F5A"
          B: "#EC43A2"
          C: "#3D9A67"
          V: "#409ACA"
          O: "#3A6E8F"
          I: "#F09B58"
          K: "#F5CF94"

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

      scope.$watchCollection "data", (newData, oldData) ->
        render newData, scope.view

      scope.$watch "view", (newView, oldView) ->
        firstRun = true
        baseSvg.selectAll("*").remove()
        render scope.data, newView

      render = (data, view) ->
        renderColumnView(data) if view is "percent"
        renderDonutView(data)  if view is "mandates"

      renderColumnView = (data, key) ->
        return if !data.one or !data.two

        big = null
        small = null

        if data.one.entries.length > data.two.entries.length
          big = "one"
          small = "two"
        else if data.one.entries.length < data.two.entries.length
          big = "two"
          small = "one"

        if big and small
          loopCount = data[big].entries.length - 1

          for i in [0..loopCount]
            if !data[small].entries.hasOwnProperty i
              data[small].entries.splice i, 0, {
                "percent": 0
                "mandates": "0"
                "uncertainty": 0
                "party": data[big].entries[i].party
              }
            else if data[small].entries[i].party.letter isnt data[big].entries[i].party.letter
              data[small].entries.splice i, 0, {
                "percent": 0
                "mandates": "0"
                "uncertainty": 0
                "party": data[big].entries[i].party
              }

        if firstRun
          svg = baseSvg.append("g").attr "transform", "translate(#{svgPadding.left}, #{svgPadding.top})"
        else
          svg = baseSvg

        key or= "percent"
        svgWidth = d3.select(element[0])[0][0].offsetWidth
        compareMargin = 2;
        chartWidth = svgWidth - svgPadding.left - svgPadding.right - compareMargin
        columncount = data.one.entries.length + data.two.entries.length
        columnWidth =  24
        logoSize = columnWidth
        minColumnMargin = 5
        view = "big"

        if chartWidth - ((columnWidth * columncount) + (minColumnMargin * columncount)) <= 0
          columnWidth = 15
          view = "small"

        if chartWidth - ((columnWidth * columncount) + (minColumnMargin * columncount)) <= 0
          columnWidth = 10

        columnMargin = (chartWidth - (columnWidth * 2)) / (data.one.entries.length - 1)
        maxPercentOne = d3.max data.one.entries, (d) -> parseFloat d[key]
        maxPercentTwo = d3.max data.two.entries, (d) -> parseFloat d[key]
        maxPercent = d3.max [maxPercentOne, maxPercentTwo]
        maxYScale = Math.ceil(maxPercent / 10) * 10
        maxYScale = maxYScale - 5 if maxYScale - maxPercent > 5
        yScale = d3.scale.linear()
          .domain [0, maxYScale]
          .range [svgHeight, 0]

        yAxis = d3.svg.axis().scale(yScale).ticks(5).tickSize(-svgWidth, 0, 0).orient "left"

        if firstRun
          svg.append "g"
            .attr "class", "y axis"
            .call yAxis

        svg.selectAll(".y.axis").call yAxis

        pollOne = svg.selectAll(".poll-one.column").data(data.one.entries)

        pollOne
          .enter()
            .append "rect"
              .attr "class", "poll-one column"
              .attr "height", 0
              .attr "y", svgHeight
              .attr "fill", (d) ->  partyColors.first[d.party.letter]

        pollOne
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnMargin) + (svgPadding.left / 2)
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale(d[key])
            .attr "y", (d) -> yScale d[key]

        pollOne.exit().remove()

        pollTwo = svg.selectAll(".poll-two.column").data(data.two.entries)

        pollTwo
          .enter()
            .append "rect"
              .attr "class", "poll-two column"
              .attr "height", 0
              .attr "y", svgHeight
              .attr "fill", (d) -> partyColors.second[d.party.letter]

        pollTwo
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnMargin) + (svgPadding.left / 2) + (columnWidth + compareMargin)
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale(d[key])
            .attr "y", (d) -> yScale d[key]

        pollTwo.exit().remove()

        pollOnePercent = svg.selectAll(".poll-one.party-percent").data(data.one.entries)

        pollOnePercent
          .enter()
            .append "text"
              .attr "class", "poll-one party-percent"
              .attr "text-anchor", "middle"
              .attr "y", svgHeight

        if view is "small"
          pollOnePercent
            .text (d) -> d[key].toString().replace(".", ",")
            .transition().duration(1000)
              .attr "transform", "rotate(-90)"
              .attr "y", (d, i) -> ((i * columnMargin) + (svgPadding.left / 2)) + (columnWidth / 2) + 3
              .attr "x", (d) -> -yScale(d[key]) + 20
        else
          pollOnePercent
            .text (d) -> d[key].toString().replace(".", ",")
            .attr "x", (d, i) -> ((i * columnMargin) + (svgPadding.left / 2)) + (columnWidth / 2)
            .transition().duration(1000)
              .attr "y", (d) -> yScale(d[key]) - 7

        pollTwoPercent = svg.selectAll(".poll-two.party-percent").data(data.two.entries)

        pollTwoPercent
          .enter()
            .append "text"
              .attr "class", "poll-two party-percent"
              .attr "text-anchor", "middle"
              .attr "y", svgHeight

        if view is "small"
          pollTwoPercent
            .text (d) -> d[key].toString().replace(".", ",")
            .transition().duration(1000)
              .attr "transform", "rotate(-90)"
              .attr "y", (d, i) -> ((i * columnMargin) + (svgPadding.left / 2)) + (columnWidth / 2) + (columnWidth + compareMargin) + 6
              .attr "x", (d) -> -yScale(d[key]) + 20
        else
          pollTwoPercent
            .text (d) -> d[key].toString().replace(".", ",")
            .attr "x", (d, i) -> ((i * columnMargin) + (svgPadding.left / 2)) + (columnWidth / 2) + (columnWidth + compareMargin)
            .transition().duration(1000)
              .attr "y", (d) -> yScale(d[key]) - 7

        pollOneUncertainty = svg.selectAll(".poll-one.party-uncertainty").data(data.one.entries)

        pollOneUncertainty
          .enter()
            .append "rect"
              .attr "class", "poll-one party-uncertainty ng-hide"
              .attr "height", 0
              .attr "y", (d) -> yScale parseFloat(d[key]) + (parseFloat(d['uncertainty']) / 2)

        pollOneUncertainty
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnMargin) + (svgPadding.left / 2)
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale d['uncertainty']
            .attr "y", (d) -> yScale parseFloat(d[key]) + (parseFloat(d['uncertainty']) / 2)

        pollTwoUncertainty = svg.selectAll(".poll-two.party-uncertainty").data(data.two.entries)

        pollTwoUncertainty
          .enter()
            .append "rect"
              .attr "class", "poll-two party-uncertainty ng-hide"
              .attr "height", 0
              .attr "y", (d) -> yScale parseFloat(d[key]) + (parseFloat(d['uncertainty']) / 2)

        pollTwoUncertainty
          .attr "width", columnWidth
          .attr "x", (d, i) -> (i * columnMargin) + (svgPadding.left / 2) + (columnWidth + compareMargin)
          .transition().duration(1000)
            .attr "height", (d) -> svgHeight - yScale d['uncertainty']
            .attr "y", (d) -> yScale parseFloat(d[key]) + (parseFloat(d['uncertainty']) / 2)

        partyLogos = svg.selectAll(".party-logos").data(data.one.entries)

        partyLogos
          .enter()
            .append "image"
            .attr "class", "party-logos"
            .attr "y", svgHeight + 10
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/berlingske-barometer/img/#{d.party.letter.toLowerCase()}_big@2x.png" if retina
              return "/upload/tcarlsen/berlingske-barometer/img/#{d.party.letter.toLowerCase()}_big.png"

        partyLogos
          .attr 'width', logoSize
          .attr 'height', logoSize
          .attr "x", (d, i) -> (i * columnMargin) + (svgPadding.left / 2) + (columnWidth) - (logoSize / 2)

        firstRun = false

      renderDonutView = (data) ->
        return if !data.one or !data.two

        big = null
        small = null

        if data.one.blokEntries.length > data.two.blokEntries.length
          big = "one"
          small = "two"
        else if data.one.blokEntries.length < data.two.blokEntries.length
          big = "two"
          small = "one"

        if big and small
          loopCount = data[big].blokEntries.length - 1

          for i in [0..loopCount]
            if data[small].blokEntries[i].party.letter isnt data[big].blokEntries[i].party.letter
              data[small].blokEntries.splice i, 0, {
                "percent": 0
                "mandates": "0"
                "party": data[big].blokEntries[i].party
              }

        svgWidth = d3.select(element[0])[0][0].offsetWidth

        if svgWidth < 630
          renderColumnView data, "mandates"
          return

        pi = Math.PI
        logoSize = 30
        logoMargin = 25
        donutOneWidth = 100
        donutTwoWidth = 70
        donutmargin = 30
        frameWidth = svgWidth / 2
        frameHight = d3.select(element[0])[0][0].offsetHeight
        pollPie = d3.layout.pie().sort(null).value((d) -> return d.mandates).startAngle(-90 * (pi / 180)).endAngle(90 * (pi / 180))

        if frameWidth < frameHight
          pollOneDonutRadius = frameWidth - logoSize
        else
          pollOneDonutRadius = frameHight - logoSize - logoMargin

        pollOneDonutInnerRadius = pollOneDonutRadius - donutOneWidth
        pollTwoDonutRadius = pollOneDonutRadius - donutOneWidth - donutmargin
        pollTwoDonutInnerRadius = pollTwoDonutRadius - donutTwoWidth

        if firstRun
          pollOne = baseSvg.append("g").attr("id", "pollOne").data([data.one.blokEntries]).attr "transform", "translate(#{frameWidth}, #{frameHight})"
          pollTwo = baseSvg.append("g").attr("id", "pollTwo").data([data.two.blokEntries]).attr "transform", "translate(#{frameWidth}, #{frameHight})"
        else
          pollOne = d3.select("#pollOne").data([data.one.blokEntries])
          pollTwo = d3.select("#pollTwo").data([data.two.blokEntries])

        pollOneArc = d3.svg.arc().outerRadius(pollOneDonutRadius).innerRadius(pollOneDonutInnerRadius)
        pollTwoArc = d3.svg.arc().outerRadius(pollTwoDonutRadius).innerRadius(pollTwoDonutInnerRadius)

        pollOneSlices = pollOne.selectAll(".poll-one.slice").data(pollPie)

        pollOneSlices
          .enter()
            .append "path"
              .attr "class", "poll-one slice"
              .attr "fill", (d) -> partyColors.first[d.data.party.letter]

        pollOneSlices
          .transition().duration(1000)
            .attr "d", pollOneArc

        pollOneTexts = pollOne.selectAll(".poll-one.texts").data(pollPie)

        pollOneTexts
          .enter()
            .append "text"
              .attr "class", "poll-one texts"
              .attr "text-anchor", "middle"
              .attr "fill", "#fff"

        pollOneTexts
          .text (d, i) -> d.data.mandates
          .attr "display", (d) ->
            return "none" if d.data.mandates is "0"
            return "block"
          .transition().duration(1000)
            .attr "transform", (d) -> "translate(#{pollOneArc.centroid(d)})"

        pollTwoSlices = pollTwo.selectAll(".poll-two.slice").data(pollPie)

        pollTwoSlices
          .enter()
            .append "path"
              .attr "class", "poll-two slice"
              .attr "fill", (d) -> partyColors.second[d.data.party.letter]

        pollTwoSlices
          .transition().duration(1000)
            .attr "d", pollTwoArc

        pollTwoTexts = pollTwo.selectAll(".poll-two.texts").data(pollPie)

        pollTwoTexts
          .enter()
            .append "text"
              .attr "class", "poll-two texts"
              .attr "text-anchor", "middle"
              .attr "fill", "#fff"

        pollTwoTexts
          .text (d, i) -> d.data.mandates
          .attr "display", (d) ->
            return "none" if d.data.mandates is "0"
            return "block"
          .transition().duration(1000)
            .attr "transform", (d) -> "translate(#{pollTwoArc.centroid(d)})"

        partyLogos = pollOne.selectAll(".party-logos").data(pollPie)

        partyLogos
          .enter()
            .append "image"
            .attr "class", "party-logos"
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/berlingske-barometer/img/#{d.data.party.letter.toLowerCase()}_big@2x.png" if retina
              return "/upload/tcarlsen/berlingske-barometer/img/#{d.data.party.letter.toLowerCase()}_big.png"
            .attr 'width', logoSize
            .attr 'height', logoSize

        partyLogos
          .attr "display", (d) ->
            return "none" if d.data.mandates is "0"
            return "block"
          .transition().duration(1000)
            .attr "x", (d) ->
              c = pollOneArc.centroid(d)
              x = c[0]
              y = c[1]
              h = Math.sqrt(x*x + y*y)

              return ((x / h) * (pollOneDonutRadius + logoMargin)) - (logoSize / 2)
            .attr "y", (d) ->
               c = pollOneArc.centroid(d)
               x = c[0]
               y = c[1]
               h = Math.sqrt(x*x + y*y)

               return ((y / h) * (pollOneDonutRadius + logoMargin)) - (logoSize / 2)

        if firstRun
          baseSvg
            .append "image"
              .attr "xlink:href", "/upload/tcarlsen/berlingske-barometer/img/mandate_guide.jpg"
              .attr 'width', 150
              .attr 'height', 72
              .attr "x", 0
              .attr "y", svgPadding.top - (72 / 2)

          baseSvg
            .append "line"
              .attr "x1", 0
              .attr "y1", svgHeight + svgPadding.top + svgPadding.bottom
              .attr "x2", svgWidth
              .attr "y2", svgHeight + svgPadding.top + svgPadding.bottom
              .attr "stroke", "#999"
              .attr "stroke-width", 1

          baseSvg
            .append "line"
              .attr "x1", frameWidth
              .attr "y1", frameHight - pollOneDonutRadius - (logoMargin / 2)
              .attr "x2", frameWidth
              .attr "y2", frameHight - pollTwoDonutInnerRadius + (logoMargin / 2)
              .attr "stroke", "#000"
              .attr "stroke-width", 1
              .attr "stroke-dasharray", "2, 4"

          baseSvg
            .append "text"
              .attr "text-anchor", "middle"
              .attr "x", frameWidth
              .attr "y", frameHight - pollTwoDonutInnerRadius + logoMargin + 10
              .attr "font-weight", "bold"
              .attr "font-size", "16px"
              .text "Flertal"

        firstRun = false
