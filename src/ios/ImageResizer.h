#import <Cordova/CDVPlugin.h>

@interface ImageResizer : CDVPlugin
- (NSString *) getScaledImagePath:(NSString *)imagePath; 
@end
