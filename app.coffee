# app.coffee
# The main application thread.
{app, BrowserWindow} = require 'electron'
{client} = require 'electron-connect'
path = require 'path'
url = require 'url'
globalWindow = null

createWindow = ->
  globalWindow = new BrowserWindow
    width: 800
    height: 600
    titleBarStyle: 'hidden-inset'
    webPreferences:
      scrollBounce: yes

  globalWindow.loadURL url.format
    pathname: path.join(__dirname, 'index.html')
    protocol: 'file:'
    slashes: true

  client.create(globalWindow)

  globalWindow.on 'close', ->
    globalWindow = null

app.on('ready', createWindow)
app.on 'activate', ->
  if globalWindow is null then createWindow()
