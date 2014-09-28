importScripts("prelude-browser-min.js", "perlin.js")

pickInterpolation = (layer) ->
  layer.i = {
    stepped: sample1 stepped
    linear: sample2 linear
    cosine: sample2 cosine
    cubic: sample4 cubic
    catmullrom: sample4 catmullrom
  }[layer.i]
  layer

onmessage = (event) ->
  data = event.data
  layers = [pickInterpolation(l) for l in data.layers]
  sampler = perlin data.dims, data.level, layers
  result = [[sampler [y, x] for x til data.dims[1]] for y til data.dims[0]]
  postMessage result

