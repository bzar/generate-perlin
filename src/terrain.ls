{Obj, sum, zip-with, fold, map} = require 'prelude-ls'

# Vector functions
square = (x) -> Math.pow(x, 2)
clamp = (x, min, max) -> Math.max(min, Math.min(max, x))
scale = (s, v) --> map (* s), v
length = (v) -> Math.sqrt(sum (map square, v))
normalize = (v) -> scale (1 / length(v)), v
dot = (v, w) --> sum (zip-with (*), v, w)
sub = (v, w) -> zip-with (-), v, w

# Lighting and color
rgba = (r=0, g=0, b=0, a=0) -> {r:r, g:g,  b:b, a: a}
colorShade = (a, c) --> rgba(c.r * a, c.g * a, c.b * a, c.a)
colorFloor = (c) -> rgba(Math.floor(c.r), Math.floor(c.g), Math.floor(c.b), c.a)

material = ({diffuse = rgba(), specular = rgba(), ambient = rgba(), shininess = 4} = {}) -> {
  diffuse: diffuse,
  specular: specular,
  ambient: ambient,
  shininess: shininess
}

normalMap = (heights) -> (x, y) ->
  hr = heights x + 1, y
  hl = heights x - 1, y
  ha = heights x, y + 1
  hb = heights x, y - 1
  normalize [hb - ha, hl - hr, 1]

blend2 = (a, b)-> rgba(a.r + b.r * b.a, a.g + b.g * b.a, a.b + b.b * b.a, a.a + b.a)
blend = (colors) -> fold blend2, rgba(), colors
shadeMaterial = (material, normal, light, viewer) ->
  ambient = material.ambient
  nl = dot normal, light
  diffuse = if nl > 0 then colorShade nl, material.diffuse else rgba()
  r =  sub (scale (2 * nl), normal), light
  spec = dot r, viewer
  specular = if spec > 0 then colorShade spec^material.shininess, material.specular else rgba()
  blend [ambient, diffuse, specular]

MATERIALS = Obj.map material, {
  water:
    diffuse: rgba(16, 85, 196, 0.4)
    ambient: rgba(16, 85, 196, 0.45)
    specular: rgba(19, 99, 228, 0.15)
    shininess: 0.25
  beach:
    diffuse: rgba(204, 189, 24, 0.55)
    ambient: rgba(204, 189, 24, 0.45)
  grass:
    diffuse: rgba(14, 204, 20, 0.55)
    ambient: rgba(14, 204, 20, 0.45)
  mountain:
    diffuse: rgba(85, 73, 59, 0.5)
    ambient: rgba(85, 73, 59, 0.4)
    specular: rgba(85, 73, 59, 0.1)
    shininess: 0.5
  peak:
    diffuse: rgba(240, 240, 238, 0.55)
    ambient: rgba(240, 240, 238, 0.45)
}

materialMap = (heights, normals) -> (x, y) ->
  height = heights x, y
  normal = normals x, y
  switch
  | height < 32 => MATERIALS.water
  | height < 48 and (dot normal, [0, 0, 1]) < 0.1 => MATERIALS.beach
  | height < 128 => MATERIALS.grass
  | height < 240 => MATERIALS.mountain
  | otherwise => MATERIALS.peak

shaderMap = (materials, normals, light, viewer) -> (x, y) ->
  normal = normals x, y
  material = materials x, y
  color = shadeMaterial material, normal, light, viewer
    |> colorFloor

terrainMap = (data) ->
  light = normalize([-1, 1, 1])
  viewer = [0, 0, 1]

  heights = (x, y) ->
    yy = Math.floor(clamp(y, 0, data.length - 1))
    xx = Math.floor(clamp(x, 0, data[yy].length - 1))
    data[yy][xx]
  normals = normalMap heights
  materials = materialMap heights, normals
  shader = shaderMap materials, normals, light, viewer


