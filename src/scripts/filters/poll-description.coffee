angular.module "pollDescriptionFilter", []
  .filter "polldescription", ->
    (input, institute) ->
      output = input
      if institute is "Valgresultater"
        output = ""
      else if institute is "Berlingske Poll of Polls"
        output = "Det vægtede gennemsnit viser et gennemsnit af de #{input} politiske meningsmålinger, der er blevet offentliggjort 31 dage fra den {dato} . Da nye meningsmålinger vejer tungere end ældre, er Barometerets gennemsnit udtryk for en vægtet tendens, som giver dig et mere retvisende bud på partiernes reelle opbakning end enkeltstående meningsmålinger."

      return output
