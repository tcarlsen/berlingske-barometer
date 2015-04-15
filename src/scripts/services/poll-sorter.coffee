angular.module "pollSorterService", []
  .service "pollSorter", ($filter) ->
    sort: (data) ->
      poll = {}
      firstBlock =
        entries: []
        letters: []
        total:
          percent: 0
          mandates: 0
      secondBlock =
        entries: []
        letters: []
        total:
          percent: 0
          mandates: 0
      ruler = "blue"

      poll.result = data

      for entry in poll.result.entries.entry
        supports = parseInt(entry.supports)

        if supports is 1 or supports is 9
          firstBlock.entries.push(entry)
          firstBlock.letters.push(entry.party.letter)
          firstBlock.total.percent += parseFloat entry.percent
          firstBlock.total.mandates += parseFloat entry.mandates
        else if supports is 2
          secondBlock.entries.push(entry)
          secondBlock.letters.push(entry.party.letter)
          secondBlock.total.percent += parseFloat entry.percent
          secondBlock.total.mandates += parseFloat entry.mandates

        if supports is 9
          ruler = "red" if entry.party.letter is "A"

        firstBlock.entries = $filter('orderBy')(firstBlock.entries, 'party.letter')
        secondBlock.entries = $filter('orderBy')(secondBlock.entries, 'party.letter')

      if ruler is "red"
        poll.blokEntries = firstBlock.entries.concat secondBlock.entries
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
        poll.blokEntries = secondBlock.entries.concat firstBlock.entries
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

      poll.entries = angular.copy poll.blokEntries
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
