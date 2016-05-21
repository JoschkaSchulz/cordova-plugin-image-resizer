(function () {
    "use strict";
    var ImageResizerProxy = {
        resize: function (win, fail, args, env) {
            try {
                var filePath = ImageResizerNative.ImageResizer.resize(args);
                win(filePath);
            } catch (e) {
                fail(e);
            }
        }
    };

    require("cordova/exec/proxy").add("ImageResizer", ImageResizerProxy);
})();