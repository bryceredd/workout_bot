module.exports = {

  start: "WORKOUT_BOT_PORT=8889 node_modules/coffee-script/bin/coffee app.coffee",
  install: "npm install",

  cron: {
    reminder: { time: "0 3 * * 1", command: "node_modules/coffee-script/bin/coffee reminder.coffee"},
  },

  servers: {
    prod: {
      hosts: ["root@chelsealynnportraits.com"],
      cron: {
        reminder: { time: "0 3 * * 1", command: "node_modules/coffee-script/bin/coffee reminder.coffee"},
      },
      start: "WORKOUT_HISTORY_FILE=/root/history.json WORKOUT_BOT_PORT=8889 node_modules/coffee-script/bin/coffee app.coffee"
    }
  }
}
