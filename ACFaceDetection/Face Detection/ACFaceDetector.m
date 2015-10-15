//
//  ACFaceDetector.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/2/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "ACFaceDetector.h"
#import "UIImageView+FaceFeatures.h"

@import CoreImage;
@import ImageIO;

static ACFaceDetector *_sharedDetector = nil;

@interface ACFaceDetector () {
    CGFloat _correction;
    
    dispatch_queue_t _faceFeaturesQueue;
    dispatch_queue_t _faceEyesQueue;
}

@property (nonatomic, strong) CIDetector *detector;

@end

@implementation ACFaceDetector

#pragma mark - Public Methods

+ (ACFaceDetector *)sharedDetector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDetector = [[[ACFaceDetector class] alloc] init];
    });
    
    return _sharedDetector;
}

- (instancetype)init {
    self = [super init];
    if (self)
    {
        _correction = 2;
        
        _faceFeaturesQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACFaceDetector.faceFeaturesQueue", NULL);
        _faceEyesQueue = dispatch_queue_create("com.appscollider.ACFaceDetection.ACFaceDetector.faceEyesQueue", NULL);
    }
    return self;
}

#pragma mark - CIDetector

- (NSArray *)detectFacesFeaturesInImage:(UIImage *)image {
    if (!image) return nil;
    
    CIImage *cImage = [CIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    if (!_detector)
    {
        _detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:context
                                       options:opts];
    }
    
    opts = @{CIDetectorImageOrientation : [[cImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
    
    return [_detector featuresInImage:cImage options:opts];
}

#pragma mark - All Face Features Visualization

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
                CGFloat faceAngle = [faceFeature faceAngle];
                NSLog(@"Face rotated: %@", [faceFeature hasFaceAngle] ? [NSString stringWithFormat:@"%f", faceAngle] : @"NO");
                
                [imageView addRectInView:imageView toPoint:faceFeature.leftEyePosition withAngle:faceAngle correction:_correction transformation:transform];
                [imageView addRectInView:imageView toPoint:faceFeature.rightEyePosition withAngle:faceAngle correction:_correction transformation:transform];
                [imageView addRectInView:imageView toPoint:faceFeature.mouthPosition withAngle:faceAngle correction:_correction transformation:transform];
                
                [imageView addBoundingRect:faceFeature.bounds inView:imageView withAngle:faceAngle correction:_correction transformation:transform];
            }
            
            if (completion) completion(success);
        });
    });
}

#pragma mark - Eyes Vizualization

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
                CGFloat faceAngle = [faceFeature faceAngle];
                NSLog(@"Face rotated: %@", [faceFeature hasFaceAngle] ? [NSString stringWithFormat:@"%f", faceAngle] : @"NO");
                
                [imageView addRectInView:imageView toPoint:faceFeature.leftEyePosition withAngle:faceAngle correction:_correction transformation:transform];
                [imageView addRectInView:imageView toPoint:faceFeature.rightEyePosition withAngle:faceAngle correction:_correction transformation:transform];
            }
            
            if (completion) completion(success);
        });
    });
}

@end
