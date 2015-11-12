yaml = require 'js-yaml'
fs   = require 'fs'
request = require 'request'
sleep = require 'sleep'

deploy = 'deploy.yml'
# singularityhost = "batonpass.service.consul:7099/singularity"
singularityhost = "http://192.168.99.100:7099/singularity"

doc = yaml.safeLoad(fs.readFileSync('deploy.yml', 'utf8'))
deployid = Math.random()
console.log deployid
deployData = {}

loadRequest = (callback) ->
  data = doc.staging
  delete data['postStagingAction']
  console.log data
  request.post("#{singularityhost}/api/requests",
    {json: true, body: data}
    (err, res, body) ->
      if err
        console.log err
      else
        console.log body
        callback()
  )

loadDeploy = (callback) ->
  data = doc.deploy
  delete data['instances']
  data.requestId = doc.staging.id
  data.id = "#{deployid}"
  console.log data
  request.post("#{singularityhost}/api/deploys",
    {json: true, body: {deploy: data}}
    (err, res, body) ->
      if err
        console.log err
      else
        console.log body
        callback()
  )

checkDeploy = (callback) ->
  tryRequest = ->
    console.log "requesting data"
    request.get("#{singularityhost}/api/history/request/#{doc.staging.id}/deploy/#{deployid}",
      {json: true},
      (err, res, body) ->
        if err
          console.log err
        else
          console.log body
          if body and not body.deployResult
            sleep.sleep(5)
            tryRequest()
          else deployData = body.deployResult
          # callback
    )
  tryRequest()

resultDeploy = (callback) ->
  console.log deployData
  if deployData.deployState != 'FAILED'
    request.post("#{singularityhost}/api/requests/request/{requestId}/instances", {instances: doc.deploy.instances})


loadRequest -> loadDeploy -> checkDeploy -> resultDeploy ->