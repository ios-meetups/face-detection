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

- (NSArray *)detectFacesFeaturesInImage:(UIImage *)image;

- (void)detectFacesInImageView:(UIImageView *)imageView completion:(void(^)(BOOL success))completion;
- (void)detectEyesInImageView:(UIImageView *)imageView completion:(void(^)(BOOL success))completion;

@end
