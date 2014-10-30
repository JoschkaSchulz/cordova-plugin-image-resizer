var ImageResizer = function() {};

ImageResizer.prototype.resize = function(success, fail) {
  cordova.exec(success, fail, "ImageResizer", "resize", []);
});

var imageResizer = new ImageResizer();
module.exports = imageResizer;
