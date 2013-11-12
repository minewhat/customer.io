###
For full API docs please consult: http://customer.io/docs/api/rest.html
###

hyperquest = require 'hyperquest'
check = require 'check-types'

url = require 'url'
util = require 'util'
querystring = require 'querystring'

PROTOCOL = 'https'
PORT = 443
HOST = 'track.customer.io/api'
API_VERSION = 1

CREATE_CUSTOMER_URL = '/v1/customers/%s'
TRACK_EVENT_URL = '/v1/customers/%s/events'


class Customerio


  constructor: (siteId, secretKey) ->
    throw new TypeError 'Invalid siteId' unless typeof siteId is 'string'
    throw new TypeError 'Invalid secretKey' unless typeof secretKey is 'string'

    @siteId = siteId
    @secretKey = secretKey

    @protocol = PROTOCOL
    @host = HOST
    @port = PORT

    @requestOptions =
      auth: "#{@siteId}:#{@secretKey}"


  ###
  Definition
  PUT https://track.customer.io/api/v1/customers/{CUSTOMER_ID}

  Example request
  curl -i https://track.customer.io/api/v1/customers/5 \
     -X PUT \
     -u YOUR-SITE-ID-HERE:YOUR-SECRET-API-KEY-HERE \
     -d email=customer@example.com \
   css  -d name=Bob \
     -d plan=premium
   
  Example request JSON
  curl -i https://track.customer.io/api/v1/customers/5 \
     -X PUT \
     -H "Content-Type: application/json" \
     -u YOUR-SITE-ID-HERE:YOUR-SECRET-API-KEY-HERE \
     -d '{"email":"customer@example.com","name":"Bob","plan":"premium","array":["1","2","3"]}'
  ###
  identify: (userId, email, data, callback) ->
    throw new TypeError 'Invalid callback' unless typeof callback is 'function'
    throw new TypeError 'Invalid user id' unless typeof userId is 'string'
    throw new TypeError 'Invalid email' unless typeof email is 'string'
    throw new TypeError 'Invalid data' unless check.object data

    data.email = email
    body = JSON.stringify data
    uri = url.format {
      @protocol,
      @host,
      pathname: util.format(CREATE_CUSTOMER_URL, userId)
    }

    options = @requestOptions
    options.method = 'PUT'
    options.headers =
      'Accept': 'application/json'
      'Content-type': 'application/json'
      'Content-Length': body.length

    req = hyperquest uri, options, _responseHandler(callback)
    req.end body
    req.on 'error', (err) -> callback err


  ###
  Definition
  DELETE https://track.customer.io/api/v1/customers/{CUSTOMER_ID}

  Example request
  curl -i https://track.customer.io/api/v1/customers/5 \
     -X DELETE \
     -u YOUR-SITE-ID-HERE:YOUR-SECRET-API-KEY-HERE
  ###
  deleteCustomer: (userId, callback) ->
    throw new TypeError 'Invalid callback' unless typeof callback is 'function'
    throw new TypeError 'Invalid user id' unless typeof userId is 'string'

    uri = url.format {
      @protocol,
      @host,
      pathname: util.format(CREATE_CUSTOMER_URL, userId)
    }

    options = @requestOptions
    options.method = 'DELETE'

    req = hyperquest uri, options, _responseHandler(callback)
    req.on 'error', (err) -> callback err


  ###
  Definition
  POST https://track.customer.io/api/v1/customers/{CUSTOMER_ID}/events

  Example request
  curl -i https://track.customer.io/api/v1/customers/5/events \
     -u YOUR-SITE-ID-HERE:YOUR-SECRET-API-KEY-HERE \
     -d name=purchased \
     -d data[price]=23.45
  ###
  track: (userId, eventName, data, callback) ->
    throw new TypeError 'Invalid callback' unless typeof callback is 'function'
    throw new TypeError 'Invalid user id' unless typeof userId is 'string'
    throw new TypeError 'Invalid event name' unless typeof eventName is 'string'
    throw new TypeError 'Invalid data' unless check.object data

    attributes = {name: eventName}
    for key, value of data
      attributes["data[#{key}]"] = value

    body = querystring.stringify attributes
    uri = url.format {
      @protocol,
      @host,
      pathname: util.format(TRACK_EVENT_URL, userId)
    }

    options = @requestOptions
    options.method = 'POST'
    options.headers =
      'Accept': 'application/json'
      'Content-type': 'application/x-www-form-urlencoded'
      'Content-Length': body.length

    req = hyperquest uri, options, _responseHandler(callback)
    req.end body
    req.on 'error', (err) -> callback err



module.exports = Customerio


_responseHandler = (callback) ->

  return (err, res) ->
    return callback err if err?

    data = ''
    res.on 'data', (chunk) -> data += chunk

    res.on 'end', () ->
      return callback new Error('there is no response statusCode from the server') unless res?.statusCode?

      if res.statusCode is 401
        console.log 'ERROR BODY', data
        return callback new Error('Wrong auth credentials'), res

      if res.statusCode is 411
        console.log 'ERROR BODY', data
        return callback new Error('required content length'), res

      unless res.statusCode is 200
        console.log 'ERROR BODY', data
        return callback new Error('something went wrong'), res

      return callback null, res
