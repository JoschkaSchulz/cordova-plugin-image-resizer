var ImageResizer = function() {};

ImageResizer.prototype.resize = function(uri, width, height, success, fail) {
  cordova.exec(success, fail, "ImageResizer", "resize", [uri, width, height]);
});

var imageResizer = new ImageResizer();
module.exports = imageResizer;
