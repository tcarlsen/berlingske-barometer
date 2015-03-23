angular.module "pollSorterService", []
  .service "pollSorter", ->
    sort: (data) ->
      poll =
        entries: []
      firstBlock =
        letters: []
        total:
          percent: 0
          mandates: 0
      secondBlock =
        letters: []
        total:
          percent: 0
          mandates: 0
      ruler = "blue"

      poll.result = data

      for entry in poll.result.entries.entry
        supports = parseInt(entry.supports)

        poll.entries.push(entry)

        if supports is 1 or supports is 9
          firstBlock.letters.push(entry.party.letter)
          firstBlock.total.percent += parseFloat entry.percent
          firstBlock.total.mandates += parseFloat entry.mandates
        else if supports is 2
          secondBlock.letters.push(entry.party.letter)
          secondBlock.total.percent += parseFloat entry.percent
          secondBlock.total.mandates += parseFloat entry.mandates

        if supports is 9
          ruler = "red" if entry.party.letter is "A"

      if ruler is "red"
        poll.totals = [
          {
            percent: firstBlock.total.percent.toFixed(1)
            mandates: firstBlock.total.mandates
            color:
              first: "#BB242E"
              second: "#D77C83"
            letters: firstBlock.letters.sort().join("")
          }
          {
            percent: secondBlock.total.percent.toFixed(1)
            mandates: secondBlock.total.mandates
            color:
              first: "#136A90"
              second: "#74A6BC"
            letters: secondBlock.letters.sort().join("")
          }
        ]
      else
        poll.totals = [
          {
            percent: secondBlock.total.percent
            mandates: secondBlock.total.mandates
            color:
              first: "#BB242E"
              second: "#D77C83"
            letters: secondBlock.letters.sort().join("")
          }
          {
            percent: firstBlock.total.percent
            mandates: firstBlock.total.mandates
            color:
              first: "#136A90"
              second: "#74A6BC"
            letters: firstBlock.letters.sort().join("")
          }
        ]

      poll.entries.sort (a, b) ->
        a = a.party.letter
        b = b.party.letter

        getInt = (c) ->
          c = c.toLowerCase().charCodeAt(0)

          switch c
            when 229 then 299 #å
            when 248 then 298 #ø
            when 230 then 297 #æ
            else c

        d = getInt(a)
        e = getInt(b)

        if d isnt e
          return d - e

      return poll
