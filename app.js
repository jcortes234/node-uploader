var express = require('express')
  , http = require('http')
  , path = require('path')
  , fs = require('fs');;

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.limit('50gb'));
  app.use(express.bodyParser({ 
    keepExtensions: true, 
    uploadDir: __dirname + '/tmp'
  }));
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

// Routes

app.get('/', function(req, res) {
  res.render('index');
});

app.post('/', function(req, res) {
  //copyFile(req.files.myFile.path, __dirname+'/'+req.files.myFile.filename);
  res.end();
});

// Start the app

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});

function copyFile(source, target) {

  var rd = fs.createReadStream(source);
  rd.on("error", function(err) {
    //done(err);
  });
  var wr = fs.createWriteStream(target);
  wr.on("error", function(err) {
    //done(err);
  });
  wr.on("close", function(ex) {
    //done(source);
  });
  rd.pipe(wr);
  
  console.log("Copying to "+target);

  fs.unlink(source);
  console.log("Deleting "+source);
  
}
