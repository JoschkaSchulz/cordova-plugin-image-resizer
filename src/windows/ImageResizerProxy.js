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
				var config = new ImageResizerNative.Config();
				config.Uri = argConfig.uri;
				config.FolderName = argConfig.folderName;
				config.Quality = argConfig.quality;
				config.Width = argConfig.width;
				config.Height = argConfig.height;
				config.FileName = argConfig.fileName;
                var filePath = ImageResizerNative.ImageResizer.resize(config);
                win(filePath);
            } catch (e) {
                fail(e);
            }
        }
    };

    require("cordova/exec/proxy").add("ImageResizer", ImageResizerProxy);
})();