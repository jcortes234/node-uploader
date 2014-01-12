module.exports = (id)->
  '''
    <!DOCTYPE html>
      <html>
        <head>
          <title>FestivalOpen! Uploader</title>
          <link rel="stylesheet" href="/stylesheets/bootstrap.min.css">
          <link rel="stylesheet" href="/stylesheets/style.css">
        </head>
        <body>
          <div class="container">
           <div class="row">
           <div class="span12">
            <form method="post" action="/" enctype="multipart/form-data">
              <legend>Upload File</legend>
              <input type="file" name="videoFile" id="videoFile">
              <input type="hidden" name="idFile" id="idFile" value="'''+id+'''">
              <p></p>
              <div class="form-actions">
                <input type="submit" value="Start" class="btn btn-primary">
              </div>
            </form>
          </div>
          </div>
          <hr>
          <div class="row">
            <div class="span12"></div>
            <legend>Support: contacto@festivalopen.com</legend>
          </div>
          <hr>
          <div class="row">
            <div class="span12">
              <div class="progress progress-striped active hide">
              <div style="width: 0%" class="bar">
            </div>
          </div>
          </div>
          </div>
          <div class="row">
            <div class="span12"><div class="alert hide"><button type="button" data-dismiss="alert" class="close">x</button><span><strong class="message"></strong></span></div></div></div></div><script src="/javascripts/jquery-1.9.1.min.js"></script><script src="/javascripts/bootstrap.min.js"></script><script src="/javascripts/script.js"></script></body></html>
  '''
