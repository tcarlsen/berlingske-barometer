angular.module "pollDateFilter", []
  .filter "polldate", ->
    (input) ->
      new Date input.replace(" ", "T") || ""
