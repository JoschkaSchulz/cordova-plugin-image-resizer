#import "ImageResizer.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ImageResizer

- (void) resize:(CDVInvokedUrlCommand*)command
{
    NSDictionary* arguments = [command.arguments objectAtIndex:0];

    //Get the image from the path
    NSString *imageUrlString = [arguments objectForKey:@"url"];
    NSURL *imageURL = [NSURL URLWithString:imageUrlString];
    UIImage* sourceImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: imageURL]];

    CGSize frameSize = CGSizeMake([[arguments objectForKey:@"width"] floatValue], [[arguments objectForKey:@"height"] floatValue]);
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;

    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(MIN(width * scaleFactor, targetWidth), MIN(height * scaleFactor, targetHeight));
    }

    // If the pixels are floats, it causes a white line in iOS8 and probably other versions too
    scaledSize.width = (int)scaledSize.width;
    scaledSize.height = (int)scaledSize.height;

    UIGraphicsBeginImageContext(scaledSize); // this will resize

    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }

    // pop the context to get back to the default
    UIGraphicsEndImageContext();

    // get the temp directory path
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by apple (vs [NSFileManager defaultManager]) to be threadsafe
    // generate unique file name
    NSString* filePath;
    NSData* data = UIImageJPEGRepresentation(newImage, 90.0f / 100.0f);

    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%.%@", docsPath, @"protonet_", i++, @"jpg"];
    } while ([fileMgr fileExistsAtPath:filePath]);

    // save file
    CDVPluginResult* result = nil;
    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
