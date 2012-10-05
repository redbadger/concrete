express = require 'express'
stylus = require 'stylus'
fs = require 'fs'
path = require 'path'
colors = require 'colors'
jobs = require './jobs'
git = require './git'
runner = require './runner'
config = require path.normalize process.cwd() + '/concrete.yml'
_ = require 'underscore'

#For HTTP basic authentication
requireAuth = express.basicAuth (user, pass) ->
  return true if not config.concrete.auth?
  return config.concrete.auth.user is user and config.concrete.auth.password is pass

module.exports = app = express()

app.configure ->
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.set 'view options', layout: false
    app.use express.logger()
    app.use express.bodyParser()
    app.use app.router
    app.use require('connect-assets')(src: __dirname + '/assets')
    app.use express.static __dirname + '/public'

app.configure 'development', ->
    app.use express.errorHandler dumpExceptions: on, showStack: on

app.configure 'production', ->
    app.use express.errorHandler dumpExceptions: on, showStack: on

app.get '/', requireAuth, (req, res) ->
    jobs.getAll (jobs)->
        res.render 'index',
            project: path.basename process.cwd()
            jobs: jobs

app.get '/jobs', requireAuth, (req, res) ->
    jobs.getAll (jobs)->
        res.json jobs

app.get '/job/:id', requireAuth, (req, res) ->
    jobs.get req.params.id, (job) ->
        res.json job

app.get '/job/:id/:attribute',requireAuth, (req, res) ->
    jobs.get req.params.id, (job) ->
        if job[req.params.attribute]?
            # if req.xhr...
            res.json job[req.params.attribute]
        else
            res.send "The job doesn't have the #{req.params.attribute} attribute"

app.get '/clear',requireAuth, (req, res) ->
    jobs.clear ->
        res.redirect "/jobs"

app.get '/add',requireAuth, (req, res) ->
    jobs.addJob ->
        res.redirect "/jobs"

app.get '/ping',requireAuth, (req, res) ->
    jobs.getLast (job) ->
        if job.failed
            res.send(412)
        else
            res.send(200)

app.post '/',requireAuth, (req, res) ->
    jobs.addJob (job)->
        runner.build()
        if req.xhr
            console.log job
            res.json job
        else
            res.redirect "/"

app.post '/hook', (req, res) ->
    unless req.body
      console.log "GitHub JSON is malformed".red
      res.send 500

    if req.body.ref and _.last(req.body.ref.split('/')) is git.branch
      jobs.addJob (job)->
        runner.build()
        console.log 'GitHub hook triggered a build.'.yellow
        res.send 200
    else
      console.log 'GitHub hook ignored as it is not a monitored branch.'.yellow
      res.send 200