cordova.commandProxy.add("ImageResizer",{
    resize: function (win, fail, args, env) {
        try {
            var filePath = ImageResizer.ImageResizer.resize(args);
            win(filePath);
        } catch (e) {
            fail(e);
        }
    }
});