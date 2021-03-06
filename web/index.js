// Generated by LiveScript 1.2.0
var each, getLog, init, generate, heightMap, terrain, render, tickPrev, tick;
each = require('prelude-ls').each;
getLog = function(){
  var logElement;
  logElement = document.querySelector("#log");
  return function(msg){
    return logElement.textContent = logElement.textContent + msg + "\n";
  };
};
init = function(){
  var dims, layers;
  dims = [256, 256];
  layers = [
    {
      f: 3,
      a: 128,
      i: "linear"
    }, {
      f: 4,
      a: 256,
      i: "catmullrom"
    }, {
      f: 10,
      a: 128,
      i: "cosine"
    }, {
      f: 22,
      a: 64,
      i: "cubic"
    }, {
      f: 47,
      a: 16,
      i: "cosine"
    }, {
      f: 91,
      a: 4,
      i: "stepped"
    }, {
      f: 174,
      a: 2,
      i: "catmullrom"
    }
  ];
  document.querySelector("#width").value = dims[1];
  document.querySelector("#height").value = dims[0];
  document.querySelector("#layers").value = JSON.stringify(layers);
  return document.querySelector("#params").onsubmit = function(e){
    var width, height, layers;
    e.preventDefault();
    width = document.querySelector("#width").value;
    height = document.querySelector("#height").value;
    layers = JSON.parse(document.querySelector("#layers").value);
    return generate([height, width], layers);
  };
};
generate = function(dims, layers){
  var log, this$ = this;
  log = getLog();
  log("Generating height map");
  tick();
  return heightMap(dims, layers, function(hm){
    log(" -> " + tick() + " ms");
    log("Generating terrain");
    return terrain(hm, function(ter){
      log(" -> " + tick() + " ms");
      log("Rendering");
      render(ter, dims);
      log(" -> " + tick() + " ms");
      return log("Done");
    });
  });
};
heightMap = function(dims, layers, cb){
  var worker;
  worker = new Worker("perlinworker.js");
  worker.onmessage = function(event){
    return cb(event.data);
  };
  return worker.postMessage({
    dims: dims,
    level: -196,
    layers: layers
  });
};
terrain = function(data, cb){
  var worker;
  worker = new Worker("terrainworker.js");
  worker.onmessage = function(event){
    return cb(event.data);
  };
  return worker.postMessage(data);
};
render = function(data, dims){
  var canvas, tileHeight, tileWidth, ctx, renderTile, poss, res$, i$, to$, y, j$, to1$, x;
  canvas = document.querySelector("#canvas");
  tileHeight = canvas.height / dims[0];
  tileWidth = canvas.width / dims[1];
  ctx = canvas.getContext("2d");
  renderTile = function(pos){
    var color;
    color = data[pos.y][pos.x];
    ctx.fillStyle = "rgb(" + color.r + ", " + color.g + ", " + color.b + ")";
    return ctx.fillRect(tileWidth * pos.x, tileHeight * pos.y, tileWidth + 1, tileHeight + 1);
  };
  res$ = [];
  for (i$ = 0, to$ = dims[0]; i$ < to$; ++i$) {
    y = i$;
    for (j$ = 0, to1$ = dims[1]; j$ < to1$; ++j$) {
      x = j$;
      res$.push({
        x: x,
        y: y
      });
    }
  }
  poss = res$;
  return each(renderTile, poss);
};
tickPrev = 0;
tick = function(prev){
  var now;
  prev == null && (prev = 0);
  now = Date.now();
  prev = tickPrev;
  tickPrev = now;
  return now - prev;
};
document.onreadystatechange = function(){
  if (document.readyState === "complete") {
    return init();
  }
};