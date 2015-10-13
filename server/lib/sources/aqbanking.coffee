# stolen code :/

spawn = require('child_process').spawn

log = (require 'printit')(
    prefix: 'sources/aqbanking'
    date: true
)

Config = require '../../models/kresusconfig'

exports.SOURCE_NAME = 'aqbanking'

Fetch = (process, bankuuid, login, password, website, callback) ->
  log.info "Fetch started: running process #{process}..."
  script = spawn process, []

  script.stdin.write bankuuid + '\n'
  script.stdin.write login + '\n'
  script.stdin.write password + '\n'
  if website?
    script.stdin.write website + '\n'
  script.stdin.end()

  body = ''
  script.stdout.on 'data', (data) ->
    body += data.toString()

  err = undefined
  script.stderr.on 'data', (data) ->
    err ?= ''
    err += data.toString()

  script.on 'close', (code) =>
    log.info "aqbanking exited with code #{code}"

    if err?
      log.info "aqbanking-stderr: #{err}"

    if not body.length
      callback "Weboob error: #{err}"
      return

    try
      body = JSON.parse body
    catch err
      callback "Error when parsing aqbanking json: #{body}"
      return

    if body.error_code?
      error =
        code: body.error_code
      if body.error_content?
        error.content = body.error_content
      callback error
      return

    log.info "aqbanking exited normally with non-empty JSON content, continuing."
    callback null, body

exports.FetchAccounts = (bankuuid, login, password, website, callback) ->
  Fetch './aqbanking/account.pl', bankuuid, login, password, website, callback

exports.FetchOperations = (bankuuid, login, password, website, callback) ->
  Fetch './aqbanking/transaction.pl', bankuuid, login, password, website, callback
