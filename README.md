# Image Resizer for Cordova #
By Joschka Schulz

## Adding the Plugin ##

Use the Cordova CLI and type in the following command:

`cordova plugin add https://github.com/protonet/cordova-plugin-image-resizer.git`

## Sample Code

At the moment the plugin is only avaible on the android platform.

### resize

    window.ImageResizer.resize(uri, folder, width, height, success, failed);

### Android Example

    window.ImageResizer.resize(uri, "Protonet Messenger", 1280, 1280,
      function(image) {
         // success: image is the new resized image
      }, function() {
        // failed: grumpy cat likes this function
      });
