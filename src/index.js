require('dotenv').config()

const express = require('express')
const path = require('path')

const serviceSettings = {
  swaggerPath: path.resolve(__dirname, './specifications/oas-file.yaml'),
  controllersPath: path.resolve(__dirname, './controllers'),
}

const { routes, validator } = require('@brdu/express-swagger')(serviceSettings)

const app = express.Router()
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

routes.map(({
  fullPath,
  method,
  controller,
  parameters,
  responses,
}) => app[method](
  fullPath,
  (req, res, next) => validator(req, res, next, parameters, responses),
  controller,
))

app.use('*', (req, res) => res.sendStatus(404))

module.exports = { sample: app }
