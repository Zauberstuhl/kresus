if not process.env.NODE_ENV? or process.env.NODE_ENV is "development"

    nock = require 'nock'

    options =
        allowUnmocked: true

    accountsGenerator = require './fixtures/weboob/accounts'
    operationsGenerator = require './fixtures/weboob/operations'

    #nock.recorder.rec() # enable or not the request recorder
    nock('http://localhost:9101', options)
        .persist()
        .log(console.log)
        .defaultReplyHeaders({'content-type': 'application/json; charset=utf-8'})
        .filteringPath(/bank\/[a-z]+\//g, 'bank/societegenerale/')
        .filteringRequestBody((path) -> return {"login":"12345","password":"54321"})
        .post('/connectors/bank/societegenerale/', {"login":"12345","password":"54321"})
        .reply(200, accountsGenerator)

    nock('http://localhost:9101', options)
        .persist()
        .log(console.log)
        .defaultReplyHeaders({'content-type': 'application/json; charset=utf-8'})
        .filteringPath(/bank\/[a-z]+\//g, 'bank/societegenerale/')
        .filteringRequestBody((path) -> return {"login":"12345","password":"54321"})
        .post('/connectors/bank/societegenerale/history', {"login":"12345","password":"54321"})
        .reply(200, () -> operationsGenerator())
