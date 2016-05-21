(function () {
    "use strict";
    var ImageResizerProxy = {
        resize: function (win, fail, args, env) {
            try {
				if(!args[0])
				{
					fail("Missing options");
				}
				var argConfig = args[0];
                var filePath = ImageResizerNative.ImageResizer.resize(JSON.stringify(argConfig));
                win(filePath);
            } catch (e) {
                fail(e);
            }
        }
    };

    require("cordova/exec/proxy").add("ImageResizer", ImageResizerProxy);
})();