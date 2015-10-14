//
//  ACImageProcessor.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/14/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "ACImageProcessor.h"

ACImageProcessor *_sharedImageProcessor = nil;

@interface ACImageProcessor () {
    dispatch_queue_t _eyesEffectQueue;
}

@end

@implementation ACImageProcessor

+ (ACImageProcessor *)sharedImageProcessor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedImageProcessor = [[[ACImageProcessor class] alloc] init];
    });
    
    return _sharedImageProcessor;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _eyesEffectQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACImageProcessor.eyesEffectQueue", NULL);
    }
    return self;
}

#pragma mark - Private Methods

- (CIImage *)applyBumpDistortionToImage:(CIImage *)image position:(CGPoint)postion context:(CIContext *)context {
    if (!image) return nil;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortion"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[CIVector vectorWithX:postion.x Y:postion.y] forKey:kCIInputCenterKey];
    [filter setValue:[NSNumber numberWithFloat:80] forKey:kCIInputRadiusKey];
    [filter setValue:[NSNumber numberWithFloat:0.4] forKey:kCIInputScaleKey];
    
    return [filter outputImage];
}

#pragma mark - Public Methods

- (void)makeBulgeEyesInImageView:(UIImageView *)imageView completion:(void (^)(UIImage *))completion {
    if (!imageView)
    {
        if (completion) completion(nil);
        return;
    }
    
    dispatch_async(_eyesEffectQueue, ^{
        UIImage *resultImage = nil;
        CIImage *image = [CIImage imageWithData:UIImageJPEGRepresentation(imageView.image, 1.0)];
        NSArray *features = [[ACFaceDetector sharedDetector] detectFacesFeaturesInImage:imageView.image];
        
        CIImage *firstPass = nil;
        CIImage *secondPass = nil;
        CIContext *context = [CIContext contextWithOptions:nil];
        
        for (CIFaceFeature *faceFeature in features)
        {
            firstPass = [self applyBumpDistortionToImage:image position:faceFeature.leftEyePosition context:context];
            secondPass = [self applyBumpDistortionToImage:firstPass position:faceFeature.rightEyePosition context:context];
        }
        
        if (secondPass)
        {
            CGImageRef processedCGImage = [context createCGImage:secondPass fromRect:[secondPass extent]];
            resultImage = [UIImage imageWithCGImage:processedCGImage];
            CGImageRelease(processedCGImage);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(resultImage);
        });
    });
}

@end
