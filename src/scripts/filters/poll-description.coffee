angular.module "pollDescriptionFilter", []
  .filter "polldescription", ->
    (input, institute) ->
      output = input
      if institute is "Valgresultater"
        output = ""
      else if institute is "Berlingske Poll of Polls"
        output = "Berlingske Barometer beregner det vægtede gennemsnit på baggrund af målinger, der er offentliggjort inden for de seneste 31 dage. Herefter tillægges de nyere målinger større indflydelse på gennemsnittet end de ældre. I perioder, hvor der offentliggøres mange målinger, vil barometeret undertrykke ældre målinger yderligere. Her vægtes blandt andet på baggrund af antallet af målinger, respondenter og dage mellem offentliggjorte målinger. I valgperioder kan det for eksempel ske, at målinger, der er ældre end 24 timer, udelukkes fra gennemsnittet. Berlingske Barometer er dermed et udtryk for en aktuel vægtet tendens, som giver dig et mere retvisende bud på partiernes reelle opbakning end enkeltstående meningsmålinger."

      return output
