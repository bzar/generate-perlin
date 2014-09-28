{zip-with, fold, empty} = require 'prelude-ls'

# N-dimensional data sampling
view = (data, vv) -> (v) -> data (vv ++ v)
sample = (data, [x, ...xs]:vector, fn) ->
  | empty vector => data vector
  | otherwise =>
    xf = Math.floor(x)
    fn (x - xf), ((p) -> sample (view data, [xf + p]), xs, fn)

sumNd = (...ms) -> (v) -> fold (-> &0 + (&1 v)), 0, ms

clamp = (x, min, max) -> Math.max(min, Math.min(max, x))
clamped = (d) -> (v) --> fold ((d, i) -> d[clamp(i, 0, d.length - 1)]), d, v
scaled = (d1, d2, data) --> (v) -> data (zip-with (*), (zip-with (/), v, d1), d2)
interpolated = (fn, data) --> (v) -> sample data, v, fn

# N-dimensional noise
noise = (amplitude, [d, ...ds]:dims) ->
  | empty dims => Math.random() * amplitude
  | otherwise => [noise(amplitude, ds) for til d]

# Layer types
constantLayer = (value) -> (v) -> value

perlinLayer = (freqs, amplitude, dims, interpolation) ->
  noise(amplitude, freqs)
    |> clamped
    |> interpolated interpolation
    |> scaled dims, freqs

# Perlin noise
perlin = (dims, level, layers) ->
  layers = [perlinLayer([d.f for til dims.length], d.a, dims, d.i) for d in layers]
  sumNd constantLayer(level), ...layers

# Interpolation methods
sample1 = (fn) -> (t, f) -> fn t, f(0)
sample2 = (fn) -> (t, f) -> fn t, f(0), f(1)
sample4 = (fn) -> (t, f) -> fn t, f(0), f(1), f(-1), f(2)

linear = (t, a, b) -> (b - a) * t + a
stepped = (t, a, b) -> a
cosine = (t, a, b) -> t2 = (1 - Math.cos(t * Math.PI)) / 2; a * (1 - t2) + b * t2
cubic = (mu, y1, y2, y0, y3) ->
  mu2 = mu * mu
  a0 = y3 - y2 - y0 + y1
  a1 = y0 - y1 - a0
  a2 = y2 - y0
  a3 = y1
  a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3

catmullrom = (mu, y1, y2, y0, y3) ->
  mu2 = mu * mu
  a0 = -0.5*y0 + 1.5*y1 - 1.5*y2 + 0.5*y3;
  a1 = y0 - 2.5*y1 + 2*y2 - 0.5*y3;
  a2 = -0.5*y0 + 0.5*y2;
  a3 = y1;
  a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3

