request = require 'request'

_url = "https://www.festivalopen.com/ariel2014/api"

module.exports.post = (url, data, done) ->
	request.post
    url: "#{_url}#{url}"
    form: data
    , (err, status, body) ->
      body = JSON.parse(body)
      if err or status.statusCode isnt 200 or body.success is false
        return done
        	err: err
      done(null, body)