Customerio = require '../src/Customerio'

cio = new Customerio '<YOUR_SITE_ID>', '<YOUR_SECRET_KEY>'

data =
  'amount': 10
  'quantity': 3
  'total': 30

cio.track '50b896ddc814556766000001', 'purchased', data, (err, res) ->

  if err?
    console.log 'ERROR', err

  console.log 'response headers', res.headers
  console.log 'status code', res.statusCode
