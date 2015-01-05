angular.module "pollGetterService", []
  .service "pollGetter", ($http, $location) ->
    get: (year, url) ->
      url = "#{year}/#{url}" if year?
      url = "/upload/webred/bmsandbox/opinion_poll/#{url}"
      url = "http://localhost:9292/www.b.dk#{url}" if $location.$$host is "localhost"
      promise = $http.get url,
        transformResponse: (data) ->
          x2js = new X2JS()
          return x2js.xml_str2json(data)
      .then ((response) ->
        return {
          json: response.data.result
          year: year
        }
      ), (data) ->
        return {
          error: data.status
        }
