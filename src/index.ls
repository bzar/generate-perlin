{each} = require 'prelude-ls'

getLog = ->
  logElement = document.querySelector "\#log"
  (msg) -> logElement.textContent = logElement.textContent + msg + "\n"

# Main
init = ->
  dims = [256, 256]
  layers = [
    {f: 3, a: 128, i: "linear"},
    {f: 4, a: 256, i: "catmullrom"},
    {f: 10, a: 128, i: "cosine"},
    {f: 22, a: 64, i: "cubic"},
    {f: 47, a: 16, i: "cosine"},
    {f: 91, a: 4, i: "stepped"},
    {f: 174, a: 2, i: "catmullrom"}
  ]

  document.querySelector("\#width").value = dims[1]
  document.querySelector("\#height").value = dims[0]
  document.querySelector("\#layers").value = JSON.stringify(layers)
  document.querySelector("\#params").onsubmit = (e) ->
    e.preventDefault()
    width = document.querySelector("\#width").value
    height = document.querySelector("\#height").value
    layers = JSON.parse(document.querySelector("\#layers").value)
    generate([height, width], layers)

generate = (dims, layers) ->
  log = getLog!
  log "Generating height map"
  tick!
  heightMap dims, layers, (hm) ~>
    log " -> #{tick!} ms"
    log "Generating terrain"
    terrain hm, (ter) ~>
      log " -> #{tick!} ms"
      log "Rendering"
      render ter, dims
      log " -> #{tick!} ms"
      log "Done"

heightMap = (dims, layers, cb) ->
  worker = new Worker("perlinworker.js")
  worker.onmessage = (event) -> cb event.data
  worker.postMessage {dims, level: -196, layers}

terrain = (data, cb) ->
  worker = new Worker("terrainworker.js")
  worker.onmessage = (event) -> cb event.data
  worker.postMessage data

render = (data, dims) ->
  canvas = document.querySelector "\#canvas"

  tileHeight = canvas.height / dims[0]
  tileWidth = canvas.width / dims[1]

  ctx = canvas.getContext "2d"

  renderTile = (pos) ->
    color = data[pos.y][pos.x]
    ctx.fillStyle = "rgb(#{color.r}, #{color.g}, #{color.b})"
    ctx.fillRect(tileWidth * pos.x, tileHeight * pos.y, tileWidth + 1, tileHeight + 1)
  poss = [{x:x, y:y} for y til dims[0] for x til dims[1] ]
  each(renderTile, poss)

tickPrev = 0
tick = (prev = 0) -> 
  now = Date.now()
  prev = tickPrev
  tickPrev := now
  now - prev

document.onreadystatechange = -> if document.readyState == "complete" then do init
