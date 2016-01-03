fs = require 'fs'
express = require 'express'
request = require 'request'
moment = require 'moment'
bodyParser = require 'body-parser'

BOT_ID = process.env.BOT_ID || "asdf123"
WORKOUT_HISTORY_FILE = process.env.WORKOUT_HISTORY_FILE || "history.json"

readHistory = ->
  JSON.parse fs.readFileSync WORKOUT_HISTORY_FILE

writeHistory = (data) ->
  fs.writeFileSync WORKOUT_HISTORY_FILE, JSON.stringify data

exports.createServer = ->
  app = express()
  app.use bodyParser.json()

  app.post "/", (req, res) ->

    console.log req.body
    return unless req.body.sender_type is 'user'

    matches  = /([0-9]+)\s*\/\s*([0-9]+)/i.exec req.body.text
    return if matches == null || matches.length <= 2

    completed = +matches[1]
    total = +matches[2]
    
    return if total == 0
 
    week = moment().subtract(3, 'days').week()

    history = readHistory()
    history[req.body.name] ?= {}
    history[req.body.name][moment().year()] ?= {} 
    history[req.body.name][moment().year()][week] = +completed / +total
    writeHistory history

    totalPercents = (value for key, value of history[req.body.name][moment().year()]).reduce (a, b) -> a + b
    percent = totalPercents / (Object.keys(history[req.body.name][moment().year()]).length || 1)
    
    body = {
      bot_id: BOT_ID,
      text: "Master #{req.body.name}, #{completed}/#{total} for week #{week} brings you to #{percent * 100}% for the year"
    }

    request.post {url: "https://api.groupme.com/v3/bots/post", json: true, body}, (e, r, b) ->
      console.log e, b

  app.get "/", (req, res) ->
    res.send "Alive"

if module == require.main
  app = exports.createServer()
  port = process.env.WORKOUT_BOT_PORT || 8889
  app.listen port
  console.log """
  Running WORKOUT_BOT on #{port}
  """
