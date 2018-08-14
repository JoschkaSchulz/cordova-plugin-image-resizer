#import "ImageResizer.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define PROTONET_PHOTO_PREFIX @"protonet_"
#define TIMESTAMP [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

@implementation ImageResizer {
    UIImage* sourceImage;
}

- (void) resize:(CDVInvokedUrlCommand*)command
{
    __block PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
    
    imageRequestOptions.synchronous = YES;
    
    NSLog(@"IMAGE RESIZER START ----------------------------------------------------------------------------");
    
    // get the arguments and the stuff inside of it
    NSDictionary* arguments = [command.arguments objectAtIndex:0];
    NSString* imageUrlString = [arguments objectForKey:@"uri"];
    NSLog(@"Image Resizer Image URL : %@",imageUrlString);
    
    NSString* quality = [arguments objectForKey:@"quality"];
    CGSize frameSize = CGSizeMake([[arguments objectForKey:@"width"] floatValue], [[arguments objectForKey:@"height"] floatValue]);
    NSString* fileName = [arguments objectForKey:@"fileName"];
    
    BOOL asBase64 = [[arguments objectForKey:@"base64"] boolValue];
    BOOL fixRotation = [[arguments objectForKey:@"fixRotation"] boolValue];
    
    // Check if the file is a local file, and if so, read with file manager to avoid NSUrl -1022 error
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageUrlString]){
        sourceImage = [UIImage imageWithData: [[NSFileManager defaultManager] contentsAtPath:imageUrlString]];
    }else {
        sourceImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageUrlString]]];
    }    
    
    int rotation = 0;
    
    switch ([sourceImage imageOrientation]) {
        case UIImageOrientationUp:
            rotation = 0;
            break;
        case UIImageOrientationDown:
            rotation = 180;
            break;
        case UIImageOrientationLeft:
            rotation = 270;
            break;
        case UIImageOrientationRight:
            rotation = 90;
            break;
        default:
            break;
    }
    
    PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[fileName] options:nil];
    [savedAssets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        //this gets called for every asset from its localIdentifier you saved
        
        [[PHImageManager defaultManager]
         requestImageDataForAsset:asset
         options:imageRequestOptions
         resultHandler:^(NSData *imageData, NSString *dataUTI,
                         UIImageOrientation orientation,
                         NSDictionary *info)
         {
             sourceImage  = [UIImage imageWithData:imageData];
         }];
        
    }];
    
    NSLog(@"image resizer:%@",  (sourceImage ? @"image exists" : @"null" ));
    
    UIImage *tempImage = nil;
    CGSize targetSize = frameSize;
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    
    // get original image dimensions
    CGFloat heightInPoints = sourceImage.size.height;
    CGFloat heightInPixels = heightInPoints * sourceImage.scale;
    CGFloat widthInPoints = sourceImage.size.width;
    CGFloat widthInPixels = widthInPoints * sourceImage.scale;
    
    // calculate the target dimensions in a way that preserves the original aspect ratio
    CGFloat newWidth = targetSize.width;
    CGFloat newHeight = targetSize.height;
    
    if (heightInPixels > widthInPixels) {
        // vertical image: use targetSize.height as reference for scaling
        newWidth = widthInPixels * newHeight / heightInPixels;
    } else {
        // horizontal image: use targetSize.width as reference
        newHeight = heightInPixels * newWidth / widthInPixels;
    }
    
    thumbnailRect.size.width  = newWidth;
    thumbnailRect.size.height = newHeight;
    targetSize.width = newWidth;
    targetSize.height = newHeight;
    
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"image resizer:%@",  (tempImage  ? @"image exsist" : @"null" ));
    
    if(fixRotation){
        tempImage = [self rotateImage:tempImage withRotation:rotation];
    }
    
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(tempImage, [quality floatValue] / 100.0f );
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachesDirectory isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *imagePath =[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"img%@.jpeg", TIMESTAMP]];
    CDVPluginResult* result = nil;
    
    if (asBase64) {
        NSData *imageBase64 = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *imageBase64String = [[NSString alloc] initWithData:imageBase64 encoding:NSUTF8StringEncoding];
        NSString *imageBase64URL = [NSString stringWithFormat:@"%@%@", @"data:image/jpeg;base64,", imageBase64String];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imageBase64URL];
    }
    else if (![imageData writeToFile:imagePath atomically:NO])
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"error save image"];
    }
    else
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:imagePath] absoluteString]];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (UIImage*) rotateImage:(UIImage*) image withRotation:(int) rotation{
    CGFloat rot = rotation * M_PI / 180;
    
    // Calculate Destination Size
    CGAffineTransform t = CGAffineTransformMakeRotation(rot);
    CGRect sizeRect = (CGRect) {.size = image.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, rot);
    [image drawInRect:CGRectMake(-image.size.width / 2.0f, -image.size.height / 2.0f, image.size.width, image.size.height)];
    
    // Save image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
