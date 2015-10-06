//
//  UIImageView+Subviews.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/5/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "UIImageView+Subviews.h"

@implementation UIImageView (Subviews)

- (void)removeAllSubviews {
    NSArray *viewsToRemove = [self subviews];
    for (UIView *view in viewsToRemove) [view removeFromSuperview];
}

@end
