Customerio = require '../src/Customerio'

cio = new Customerio '<YOUR_SITE_ID>', '<YOUR_SECRET_KEY>'

cio.identify '50b896ddc814556766000001', 'fab@bizzby.com', {created_at:new Date()}, (err, res) ->

  if err?
    console.log 'ERROR', err

  console.log 'response headers', res.headers
  console.log 'status code', res.statusCode
