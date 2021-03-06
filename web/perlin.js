// Generated by LiveScript 1.2.0
var ref$, zipWith, fold, empty, view, sample, sumNd, clamp, clamped, scaled, interpolated, noise, constantLayer, perlinLayer, perlin, sample1, sample2, sample4, linear, stepped, cosine, cubic, catmullrom, slice$ = [].slice;
ref$ = require('prelude-ls'), zipWith = ref$.zipWith, fold = ref$.fold, empty = ref$.empty;
view = function(data, vv){
  return function(v){
    return data(vv.concat(v));
  };
};
sample = function(data, vector, fn){
  var x, xs, xf;
  x = vector[0], xs = slice$.call(vector, 1);
  switch (false) {
  case !empty(vector):
    return data(vector);
  default:
    xf = Math.floor(x);
    return fn(x - xf, function(p){
      return sample(view(data, [xf + p]), xs, fn);
    });
  }
};
sumNd = function(){
  var ms;
  ms = slice$.call(arguments);
  return function(v){
    return fold(function(){
      return arguments[0] + arguments[1](v);
    }, 0, ms);
  };
};
clamp = function(x, min, max){
  return Math.max(min, Math.min(max, x));
};
clamped = function(d){
  return function(v){
    return fold(function(d, i){
      return d[clamp(i, 0, d.length - 1)];
    }, d, v);
  };
};
scaled = curry$(function(d1, d2, data){
  return function(v){
    return data(zipWith(curry$(function(x$, y$){
      return x$ * y$;
    }), zipWith(curry$(function(x$, y$){
      return x$ / y$;
    }), v, d1), d2));
  };
});
interpolated = curry$(function(fn, data){
  return function(v){
    return sample(data, v, fn);
  };
});
noise = function(amplitude, dims){
  var d, ds, i$, results$ = [];
  d = dims[0], ds = slice$.call(dims, 1);
  switch (false) {
  case !empty(dims):
    return Math.random() * amplitude;
  default:
    for (i$ = 0; i$ < d; ++i$) {
      results$.push(noise(amplitude, ds));
    }
    return results$;
  }
};
constantLayer = function(value){
  return function(v){
    return value;
  };
};
perlinLayer = function(freqs, amplitude, dims, interpolation){
  return scaled(dims, freqs)(
  interpolated(interpolation)(
  clamped(
  noise(amplitude, freqs))));
};
perlin = function(dims, level, layers){
  var res$, i$, len$, d;
  res$ = [];
  for (i$ = 0, len$ = layers.length; i$ < len$; ++i$) {
    d = layers[i$];
    res$.push(perlinLayer((fn$()), d.a, dims, d.i));
  }
  layers = res$;
  return sumNd.apply(null, [constantLayer(level)].concat(slice$.call(layers)));
  function fn$(){
    var i$, to$, results$ = [];
    for (i$ = 0, to$ = dims.length; i$ < to$; ++i$) {
      results$.push(d.f);
    }
    return results$;
  }
};
sample1 = function(fn){
  return function(t, f){
    return fn(t, f(0));
  };
};
sample2 = function(fn){
  return function(t, f){
    return fn(t, f(0), f(1));
  };
};
sample4 = function(fn){
  return function(t, f){
    return fn(t, f(0), f(1), f(-1), f(2));
  };
};
linear = function(t, a, b){
  return (b - a) * t + a;
};
stepped = function(t, a, b){
  return a;
};
cosine = function(t, a, b){
  var t2;
  t2 = (1 - Math.cos(t * Math.PI)) / 2;
  return a * (1 - t2) + b * t2;
};
cubic = function(mu, y1, y2, y0, y3){
  var mu2, a0, a1, a2, a3;
  mu2 = mu * mu;
  a0 = y3 - y2 - y0 + y1;
  a1 = y0 - y1 - a0;
  a2 = y2 - y0;
  a3 = y1;
  return a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3;
};
catmullrom = function(mu, y1, y2, y0, y3){
  var mu2, a0, a1, a2, a3;
  mu2 = mu * mu;
  a0 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3;
  a1 = y0 - 2.5 * y1 + 2 * y2 - 0.5 * y3;
  a2 = -0.5 * y0 + 0.5 * y2;
  a3 = y1;
  return a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3;
};
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}