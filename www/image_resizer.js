var ImageResizer = function() {};

ImageResizer.prototype.resize = function(uri, folderName, width, height, success, fail) {
  cordova.exec(function(uri) {
    success(uri);
  }, function() {
    fail();
  }, "ImageResizer", "resize", [{uri: uri, folderName: folderName, width: width, height: height}]);
};

var imageResizer = new ImageResizer();
module.exports = imageResizer;
