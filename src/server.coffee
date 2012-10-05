express = require 'express'
stylus = require 'stylus'
fs = require 'fs'
path = require 'path'
colors = require 'colors'
jobs = require './jobs'
_ = require 'underscore'

app = express()

module.exports = (config) ->
    _.extend app, 
      config: config
      runner: require('./runner')(config)

authorize = (user, pass) ->
    user == app.config.auth.user and pass == app.config.auth.pass

app.configure ->
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.set 'view options', layout: false
    app.use express.logger()
    app.use app.router
    app.use require('connect-assets')(src: __dirname + '/assets')
    app.use express.static __dirname + '/public'

app.configure 'development', ->
    app.use express.errorHandler dumpExceptions: on, showStack: on

app.configure 'production', ->
    app.use express.errorHandler dumpExceptions: on, showStack: on

app.get '/', (req, res) ->
    jobs.getAll (jobs)->
        res.render 'index',
            project: path.basename process.cwd()
            jobs: jobs

app.get '/jobs', (req, res) ->
    jobs.getAll (jobs)->
        res.json jobs

app.get '/job/:id', (req, res) ->
    jobs.get req.params.id, (job) ->
        res.json job

app.get '/job/:id/:attribute', (req, res) ->
    jobs.get req.params.id, (job) ->
        if job[req.params.attribute]?
            # if req.xhr...
            res.json job[req.params.attribute]
        else
            res.send "The job doesn't have the #{req.params.attribute} attribute"

app.get '/clear', (req, res) ->
    jobs.clear ->
        res.redirect "/jobs"

app.get '/add', (req, res) ->
    jobs.addJob ->
        res.redirect "/jobs"

app.get '/ping', (req, res) ->
    jobs.getLast (job) ->
        if job.failed
            res.send(412)
        else
            res.send(200)

app.post '/', (req, res) ->
    jobs.addJob (job)->
        app.runner.build()
        if req.xhr
            console.log job
            res.json job
        else
            res.redirect "/"
