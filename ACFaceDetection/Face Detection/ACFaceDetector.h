//
//  ACFaceDetector.h
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/2/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACFaceDetector : NSObject

+ (ACFaceDetector *)sharedDetector;

- (void)detectFacesInImageView:(UIImageView *)imageView completion:(void(^)(BOOL success))completion;
- (void)detectEyesInImageView:(UIImageView *)imageView completion:(void(^)(BOOL success))completion;
- (void)makeBulgeEyesInImageView:(UIImageView *)imageView completion:(void(^)(UIImage *image))completion;

@end
