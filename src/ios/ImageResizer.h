#import <Cordova/CDVPlugin.h>
#import <Photos/Photos.h>
@interface ImageResizer : CDVPlugin
- (void) resize:(CDVInvokedUrlCommand*)command;
@end
