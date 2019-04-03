# ATTENTION
I don't have any time to maintain this plugin anymore. As long as no one wants to maintain it I don't see the possiblity to fix all the stuff mentioned in the issues, sorry. I recommend to not use this plugin anymore.

# Image Resizer for Cordova #
By: Protonet GmbH

Authors: Joschka Schulz

## Adding the Plugin ##
Use the Cordova CLI and type in the following command:
```

// This plugin uses the cordova-plugin-camera
cordova plugin add cordova-plugin-camera

// This plugin
cordova plugin add https://github.com/protonet/cordova-plugin-image-resizer.git
```
## Sample Code

At the moment the plugin is available on android, iOS and windows

### resize

    window.ImageResizer.resize(options, success, failed);
    
### Options

  - **uri**(String): The Uri for the image on the device to get scaled (can be file:// path (iOS,Android) or data:image base64 encoded string(Android only))
  - **folderName**(String): The name of the folder the image should be put in **android only**
  - **fileName**(String): A custom name for the file. Default name is a timestamp. **android and windows only**
  - **quality**(Number): Quality given as Number for the quality of the new image - defaults to 85 **android and iOS only**
  - **width**(Number): The width of the new image,
  - **height**(Number): The height of the new image
  - **base64**(Boolean): Whether or not to return a base64 encoded image string instead of the path to the resized image
  - **fit**(Boolean): Whether or not to fit image in bounds defined by width and height **android only**

### Android Example
```
    var options = {
          uri: uri,
          folderName: "Protonet Messenger",
          quality: 90,
          width: 1280,
          height: 1280,
          base64: true,
          fit: false
    };

    window.ImageResizer.resize(options,
      function(image) {
         // success: image is the new resized image
      }, function() {
        // failed: grumpy cat likes this function
      });
```
