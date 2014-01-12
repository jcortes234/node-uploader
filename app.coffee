async = require 'async'
formidable = require 'formidable'
fs = require 'fs'
http = require 'http'
mime = require 'mime'
path = require 'path'
request = require 'request'
url = require 'url'
util = require 'util'

response = require './lib/response'
request = require './lib/request'


cache = {}
env = process.env.NODE_ENV  || 'development'

pathVideo = (data, fileName)->
  ext = fileName.split('.')
  if env is 'development'
    dir = data.path.split('/')
    __dirname + '/video/' + data.name + '.' + ext[ext.length - 1]
  else
    data.path + data.name + '.' + ext[ext.length - 1]

server = http.createServer (req, res) ->
  console.log req.method, req.url

  if req.url is '/' and req.method.toLowerCase() is 'post'
    form = new formidable.IncomingForm()
    form.uploadDir = __dirname + '/video'
    form.maxFieldsSize = 26712580393;
    finalPath = null
    form.parse req, (err, fields, files) ->
      async.waterfall [
        (done) -> 
          request.post '/get_film_path',
            id: fields.idFile
          , done
        (data, done) -> 
          finalPath = pathVideo(data, files.videoFile.name)
          fs.rename(files.videoFile.path, finalPath, done)
        (done) ->
          request.post '/set_success',
            id: fields.idFile
            path: finalPath
            size: files.videoFile.size
          , done
      ], (err, data) ->
        response.r500(res, err) if err
        res.writeHead 200, {'content-type': 'text/plain'}
        res.write 'received upload:\n\n'
        res.end() 

    form.on 'progress', (bytesReceived, bytesExpected)->
      process.stdout.write(bytesReceived + ' ' + bytesExpected + "\r");
    
    form.on 'error', (err)->
      response.r500(res, err)

    form.on 'end', (err)->
      console.log 'Upload done'

  url_parts = url.parse(req.url,true)

  if url_parts.pathname is '/'
    res.writeHead 200, {'content-type': 'text/html'}
    res.end require('./public/index')(url_parts.query.id)

  else
    response.static(res, cache, "./public/#{req.url}")


server.listen(3000)
console.log 'listening on port 3000'
