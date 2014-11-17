#import <Cordova/CDVPlugin.h>

@interface ImageResizer : CDVPlugin
- (NSString *) resize:(NSString *)imagePath;
@end
