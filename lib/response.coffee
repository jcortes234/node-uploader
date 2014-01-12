mime = require 'mime'
path = require 'path'
fs = require 'fs'

cache = {}

exports.r404 = r404 = (res) ->
  res.writeHead 404, {'content-type': 'text/plain'}
  res.write 'Error 404: resource not found.'
  res.end()


exports.r500 =  (res, err) ->
  res.writeHead 500, err
  res.end()


exports.file = file = (res, filePath, fileContents) ->
  res.writeHead 200, 
    "content-type":mime.lookup(path.basename(filePath))
  res.end fileContents


exports.static = (res, cache, absPath) ->
  if cache[absPath] 
    return file(res, absPath, cache[absPath])
  
  fs.exists absPath, (exists) ->
    return r404(res) unless exists
      
    fs.readFile absPath, (err, data)->
      return response.r404(res) if err
      cache[absPath] = data
      file(res, absPath, data)
    
      