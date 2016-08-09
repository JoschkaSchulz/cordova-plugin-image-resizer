#import "ImageResizer.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define PROTONET_PHOTO_PREFIX @"protonet_"

@implementation ImageResizer

- (void) resize:(CDVInvokedUrlCommand*)command
{
    // get the arguments and the stuff inside of it
    NSDictionary* arguments = [command.arguments objectAtIndex:0];
    NSString* imageUrlString = [arguments objectForKey:@"uri"];
    NSString* quality = [arguments objectForKey:@"quality"];
    CGSize frameSize = CGSizeMake([[arguments objectForKey:@"width"] floatValue], [[arguments objectForKey:@"height"] floatValue]);
    NSString* fileName = [arguments objectForKey:@"fileName"];

    //Get the image from the path
    NSURL* imageURL = [NSURL URLWithString:imageUrlString];
    UIImage* sourceImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: imageURL]];
    UIImage *tempImage = nil;
    CGSize targetSize = frameSize;
    UIGraphicsBeginImageContext(targetSize);

    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;

    [sourceImage drawInRect:thumbnailRect];

    tempImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(tempImage, 0.1);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"img%ld.jpeg",(NSInteger)[[NSDate date]  timeIntervalSince1970]]];
    CDVPluginResult* result = nil;

    if (![imageData writeToFile:imagePath atomically:NO])
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"error save image"];
    }
    else
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:imagePath] absoluteString]];
    }

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
