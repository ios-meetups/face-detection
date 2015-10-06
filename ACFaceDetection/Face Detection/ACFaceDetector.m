//
//  ACFaceDetector.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/2/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "ACFaceDetector.h"

@import CoreImage;
@import ImageIO;

static ACFaceDetector *_sharedDetector = nil;

@interface ACFaceDetector () {
    CGFloat _correction;
    
    dispatch_queue_t _faceFeaturesQueue;
    dispatch_queue_t _faceEyesQueue;
    dispatch_queue_t _eyesEffectQueue;
}

@end

@implementation ACFaceDetector

+ (ACFaceDetector *)sharedDetector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDetector = [[[ACFaceDetector class] alloc] init];
    });
    
    return _sharedDetector;
}

- (id)init {
    self = [super init];
    if (self)
    {
        _correction = 2;
        
        _faceFeaturesQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACFaceDetector.faceFeaturesQueue", NULL);
        _faceEyesQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACFaceDetector.faceEyesQueue", NULL);
        _eyesEffectQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACFaceDetector.eyesEffectQueue", NULL);
    }
    return self;
}

#pragma mark - Private Methods

- (NSArray *)detectFacesFeaturesInImage:(UIImage *)image {
    if (!image) return nil;
    
    CIImage *cImage = [CIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    opts = @{CIDetectorImageOrientation : [[cImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
    
    return [detector featuresInImage:cImage options:opts];
}

- (void)addRectInView:(UIView *)view toPoint:(CGPoint)point transformation:(CGAffineTransform)transformation {
    CGFloat fWidth = 30.0f;
    CGFloat fHeight = 20.0f;
    CGRect rect = CGRectMake(point.x/_correction - fWidth/2,
                             point.y/_correction - fHeight/2,
                             fWidth,
                             fHeight);
    CGRect translatedRect = CGRectApplyAffineTransform(rect, transformation);
    
    UIView *test = [[UIView alloc] initWithFrame:translatedRect];
    [test setBackgroundColor:[UIColor purpleColor]];
    [test setAlpha:0.4];
    [test.layer setBorderColor:[UIColor blueColor].CGColor];
    [test.layer setBorderWidth:1.0];
    [view addSubview:test];
}

- (void)addBoundingRect:(CGRect)rect inView:(UIView *)view transformation:(CGAffineTransform)transformation {
    rect = CGRectMake(rect.origin.x/_correction,
                      rect.origin.y/_correction,
                      rect.size.width/_correction,
                      rect.size.height/_correction);
    CGRect translatedRect = CGRectApplyAffineTransform(rect, transformation);
    
    UIView *test = [[UIView alloc] initWithFrame:translatedRect];
    [test setBackgroundColor:[UIColor yellowColor]];
    [test setAlpha:0.3];
    [test.layer setBorderColor:[UIColor blueColor].CGColor];
    [test.layer setBorderWidth:1.0];
    [view addSubview:test];
}

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

- (void)detectFacesInImageView:(UIImageView *)imageView completion:(void (^)(BOOL))completion {
    if (!imageView)
    {
        if (completion) completion(NO);
        return;
    }
    
    dispatch_async(_faceFeaturesQueue, ^{
        BOOL success = NO;
        UIImage *image = imageView.image;
        
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -image.size.height/_correction);
        NSArray *features = [self detectFacesFeaturesInImage:image];
        if ([features count]) success = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CIFaceFeature *faceFeature in features)
            {
                [self addRectInView:imageView toPoint:faceFeature.leftEyePosition transformation:transform];
                [self addRectInView:imageView toPoint:faceFeature.rightEyePosition transformation:transform];
                [self addRectInView:imageView toPoint:faceFeature.mouthPosition transformation:transform];
                
                [self addBoundingRect:faceFeature.bounds inView:imageView transformation:transform];
            }
            
            if (completion) completion(success);
        });
    });
}

- (void)detectEyesInImageView:(UIImageView *)imageView completion:(void (^)(BOOL))completion {
    if (!imageView) 
    {
        if (completion) completion(NO);
        return;
    }
    
    dispatch_async(_faceEyesQueue, ^{
        BOOL success = NO;
        UIImage *image = imageView.image;
        
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -image.size.height/_correction);
        NSArray *features = [self detectFacesFeaturesInImage:image];
        if ([features count]) success = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CIFaceFeature *faceFeature in features)
            {
                [self addRectInView:imageView toPoint:faceFeature.leftEyePosition transformation:transform];
                [self addRectInView:imageView toPoint:faceFeature.rightEyePosition transformation:transform];
            }
            
            if (completion) completion(success);
        });
    });
}

- (void)makeBulgeEyesInImageView:(UIImageView *)imageView completion:(void (^)(UIImage *))completion {
    if (!imageView)
    {
        if (completion) completion(nil);
        return;
    }
    
    dispatch_async(_eyesEffectQueue, ^{
        UIImage *resultImage = nil;
        CIImage *image = [CIImage imageWithData:UIImageJPEGRepresentation(imageView.image, 1.0)];
        NSArray *features = [self detectFacesFeaturesInImage:imageView.image];
        
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
