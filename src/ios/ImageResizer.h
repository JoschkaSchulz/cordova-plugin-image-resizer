#import <Cordova/CDVPlugin.h>
#import <Photos/Photos.h>
@interface ImageResizer : CDVPlugin
- (void) resize:(CDVInvokedUrlCommand*)command;
- (UIImage*) rotateImage:(UIImage*) image withRotation:(int) rotation;
@end
