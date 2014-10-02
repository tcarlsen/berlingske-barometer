angular.module "pollNameFilter", []
  .filter "pollname", ->
    (input) ->
      output = input || ""
      output = "vægtet gns." if input is "Berlingske Poll of Polls"
      output = "valget" if input is "Valgresultater"

      return output.toUpperCase()
