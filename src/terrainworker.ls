importScripts("prelude-browser-min.js", "terrain.js")

onmessage = (event) ->
  data = event.data
  terrain = terrainMap data
  result = [[terrain x, y for x til data[y].length] for y til data.length]
  postMessage result

