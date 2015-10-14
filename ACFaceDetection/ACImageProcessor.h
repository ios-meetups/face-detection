//
//  ACImageProcessor.h
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/14/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACImageProcessor : NSObject

+ (ACImageProcessor *)sharedImageProcessor;

- (void)makeBulgeEyesInImageView:(UIImageView *)imageView completion:(void(^)(UIImage *image))completion;

@end
