//
//  UIImageView+FaceFeatures.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/14/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "UIImageView+FaceFeatures.h"

#define DEG_TO_RAD(__ANGLE__) ((__ANGLE__) * (M_PI / 180.0f)) // PI / 180

@implementation UIImageView (FaceFeatures)

- (void)addRectInView:(UIView *)view toPoint:(CGPoint)point withAngle:(CGFloat)angle correction:(CGFloat)correction transformation:(CGAffineTransform)transformation {
    CGFloat fWidth = 30.0f;
    CGFloat fHeight = 20.0f;
    CGRect rect = CGRectMake(point.x/correction - fWidth/2,
                             point.y/correction - fHeight/2,
                             fWidth,
                             fHeight);
    CGRect translatedRect = CGRectApplyAffineTransform(rect, transformation);
    
    UIView *test = [[UIView alloc] initWithFrame:translatedRect];
    [test setBackgroundColor:[UIColor purpleColor]];
    [test setAlpha:0.4];
    [test.layer setBorderColor:[UIColor blueColor].CGColor];
    [test.layer setBorderWidth:1.0];
    
    [test setTransform:CGAffineTransformMakeRotation(DEG_TO_RAD(angle))];
    
    [view addSubview:test];
}

- (void)addBoundingRect:(CGRect)rect inView:(UIView *)view withAngle:(CGFloat)angle correction:(CGFloat)correction transformation:(CGAffineTransform)transformation {
    rect = CGRectMake(rect.origin.x/correction,
                      rect.origin.y/correction,
                      rect.size.width/correction,
                      rect.size.height/correction);
    CGRect translatedRect = CGRectApplyAffineTransform(rect, transformation);
    
    UIView *test = [[UIView alloc] initWithFrame:translatedRect];
    [test setBackgroundColor:[UIColor yellowColor]];
    [test setAlpha:0.3];
    [test.layer setBorderColor:[UIColor blueColor].CGColor];
    [test.layer setBorderWidth:1.0];
    
    [test setTransform:CGAffineTransformMakeRotation(DEG_TO_RAD(angle))];
    
    [view addSubview:test];
}

@end
