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

demotivationalQuote = ->
  "lul"

sendMessage = (text) ->
  body = {
    bot_id: BOT_ID,
    text
  }

  request.post {url: "https://api.groupme.com/v3/bots/post", json: true, body}, (e, r, b) ->
    console.log e, b

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

    total = 1 if +total == 0

    week = moment().subtract(3, 'days').week()
    year = moment().year()
    senderId = req.body.sender_id
    isUpdate = history[sender_id][year][week] != null

    history = readHistory()
    history[senderId] ?= {}
    history[senderId][year] ?= {}
    history[senderId][year][week] = +completed / +total
    writeHistory history

    totalPercents = (value for key, value of history[senderId][year]).reduce (a, b) -> a + b
    percent = totalPercents / (Object.keys(history[senderId][year]).length || 1)
    percent = Math.floor(percent * 100)

    name = (req.body.name?.split ' ')?[0]
    message = "Master #{name}, this brings you to #{percent}% for #{year}.  "
    message += switch
      when percent < 35 then "Do remember, #{demotivationalQuote()}"
      when percent < 85 then ""
      else "I offer you my profound praise and admiration."

    if isUpdate then message = "Master #{name}, I've updated your score this week and your yearly percent is now #{percent}%"

    sendMessage message

    res.send "OK"

  app.get "/", (req, res) ->
    res.send "Alive"

if module == require.main
  app = exports.createServer()
  port = process.env.WORKOUT_BOT_PORT || 8889
  app.listen port
  console.log """
  Running WORKOUT_BOT on #{port}
  with BOT_ID #{BOT_ID}
  """
