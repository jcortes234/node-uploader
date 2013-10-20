formidable = require 'formidable'
http = require 'http'
util = require 'util'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
request = require 'request'
url = require 'url'

cache = {}
env = process.env.NODE_ENV  || 'development'

send404 = (response) ->
  console.log 'send404' 
  
  response.writeHead 404, {'content-type': 'text/plain'}
  response.write 'Error 404: resource not found.'
  response.end()

send500 = (response, err) ->
  console.log 'send500', err 
  
  response.writeHead 500, err
  response.end()


sendFile = (response, filePath, fileContents) ->
  response.writeHead 200, 
    "content-type":mime.lookup(path.basename(filePath))
  response.end fileContents


serverStatic = (response, cache, absPath) ->
  if cache[absPath] 
    sendFile response, absPath, cache[absPath]
  else
    fs.exists absPath, (exists) ->
      if exists
        fs.readFile absPath, (err, data)->
          if err
            send404 response
          else
            cache[absPath] = data
            sendFile response, absPath, data
      else
        send404 response

fs.mkdirParent = (dirPath, next) ->
  fs.mkdir dirPath, '0755', (err)->
    if err and err.errno is 34
      fs.mkdirParent(path.dirname(dirPath), next)
      fs.mkdirParent(dirPath, next)
    next(err) if next

pathVideo = (data, fileName)->
  ext = fileName.split('.')
  if env is 'development'
    dir = data.path.split('/')
    __dirname + '/video/' + dir[dir.length - 2] + '/' + data.name + '.' + ext[ext.length - 1]
  else
    data.path + data.name + '.' + ext[ext.length - 1]

getFilmPath = (id, next)->
  console.log 'getFilmPath', id
  request.post
    url: "https://www.festivalopen.com/cloudfilm/api/get_film_path"
    form:
      id:id
    , (err, status, body) ->
      body = JSON.parse(body)
      console.log body
      if err or status.statusCode isnt 200 or body.success is false
        next(err)
      else
        next(null, body)

setSuccess = (params, next) ->
  console.log 'setSuccess', params
  request.post
    url: "https://www.festivalopen.com/cloudfilm/api/set_success"
    form: params
    , (err, status, body) ->
      body = JSON.parse(body)
      if err or status.statusCode isnt 200 or body.success is false
        next(body)
      else
        next(null, body)

server = http.createServer (req, res) ->
  console.log req.method, req.url

  if req.url is '/' and req.method.toLowerCase() is 'post'
    form = new formidable.IncomingForm()
    form.uploadDir = __dirname + '/video'
    form.maxFieldsSize = 26712580393;

    form.parse req, (err, fields, files)->
      getFilmPath fields.idFile, (err, data) ->
        send500(res, err) if err 
       
        fs.mkdirParent data.path, (err)->
          finalPath = pathVideo data, files.videoFile.name
          console.log 'pathVideo', finalPath
          fs.rename files.videoFile.path, finalPath, (err)->
            send500(res, err) if err
            
            setSuccess {id: fields.idFile, path: finalPath, size: files.videoFile.size}, (err, data) ->
              send500(res, err) if err
              
              res.writeHead 200, {'content-type': 'text/plain'}
              res.write 'received upload:\n\n'
              res.end() 
    
    form.on 'progress', (bytesReceived, bytesExpected)->
      process.stdout.write(bytesReceived + ' ' + bytesExpected + "\r");
    
    form.on 'error', (err)->
      send500(res, err)

    form.on 'end', (err)->
      console.log 'Upload done'

  url_parts = url.parse(req.url,true)

  if url_parts.pathname is '/'
    res.writeHead 200, {'content-type': 'text/html'}
    res.end require('./public/index')(url_parts.query.id)

  else
    serverStatic res, cache, './public/'+req.url


server.listen(3000)
console.log 'listening on port 3000'
