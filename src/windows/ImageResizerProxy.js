(function () {
    "use strict";
    var ImageResizerProxy = {
        resize: function (win, fail, args, env) {
            try {
                if (!args[0]) {
                    fail("Missing options");
                }
                var argConfig = args[0];
                resizeImage(win, fail, argConfig);
            } catch (e) {
                fail(e);
            }
        }
    };

    var fileIO = Windows.Storage.FileIO;
    var OptUnique = Windows.Storage.CreationCollisionOption.generateUniqueName;
    var getAppData = function () {
        return Windows.Storage.ApplicationData.current;
    };
    var encodeToBase64String = function (buffer) {
        return Windows.Security.Cryptography.CryptographicBuffer.encodeToBase64String(buffer);
    };

    // Resize method
    function resizeImage(successCallback, errorCallback, config) {
        var tempPhotoFileName =  config.fileName || new Date().getTime().toString() + ".jpg";
        var file;
        var targetWidth = config.width;
        var targetHeight = config.height;
        var uri = new Windows.Foundation.Uri(config.uri);
        var storageFolder = getAppData().localFolder;
        Windows.Storage.StorageFile.getFileFromApplicationUriAsync(uri)
            .then(function (storageFile) {
                file = storageFile;
                return fileIO.readBufferAsync(storageFile);
            })
            .then(function (buffer) {
                var strBase64 = encodeToBase64String(buffer);
                var imageData = "data:" + file.contentType + ";base64," + strBase64;
                var image = new Image();
                image.src = imageData;
                image.onload = function () {
                    var ratio = Math.min(targetWidth / this.width, targetHeight / this.height);
                    var imageWidth = ratio * this.width;
                    var imageHeight = ratio * this.height;

                    var canvas = document.createElement('canvas');
                    var storageFileName;

                    canvas.width = imageWidth;
                    canvas.height = imageHeight;

                    canvas.getContext("2d").drawImage(this, 0, 0, imageWidth, imageHeight);

                    var fileContent = canvas.toDataURL(file.contentType).split(',')[1];

                    storageFolder.createFileAsync(tempPhotoFileName, OptUnique)
                        .then(function (storagefile) {
                            var content = Windows.Security.Cryptography.CryptographicBuffer.decodeFromBase64String(fileContent);
                            storageFileName = storagefile.name;
                            return fileIO.writeBufferAsync(storagefile, content);
                        })
                        .done(function () {
                            successCallback("ms-appdata:///local/" + storageFileName);
                        }, errorCallback);
                };
            })
            .done(null, function (err) {
                errorCallback(err);
            }
        );
    }

    require("cordova/exec/proxy").add("ImageResizer", ImageResizerProxy);
})();
