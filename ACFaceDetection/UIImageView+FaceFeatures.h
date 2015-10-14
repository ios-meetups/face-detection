//
//  UIImageView+FaceFeatures.h
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/14/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (FaceFeatures)

- (void)addRectInView:(UIView *)view toPoint:(CGPoint)point withAngle:(CGFloat)angle correction:(CGFloat)correction transformation:(CGAffineTransform)transformation;
- (void)addBoundingRect:(CGRect)rect inView:(UIView *)view withAngle:(CGFloat)angle correction:(CGFloat)correction transformation:(CGAffineTransform)transformation;

@end
