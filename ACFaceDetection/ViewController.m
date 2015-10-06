//
//  ViewController.m
//  ACFaceDetection
//
//  Created by Peter Petrov on 10/2/15.
//  Copyright © 2015 Apps Collider. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Subviews.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *effectButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)resetImageViewData {
    [_imageView removeAllSubviews];
    [_imageView setImage:[UIImage imageNamed:@"image.jpg"]];
}

- (IBAction)clearButtonAction:(UIButton *)sender {
    [self resetImageViewData];
}

- (IBAction)featuresButtonAction:(UIButton *)sender {
    [self resetImageViewData];
    [[ACFaceDetector sharedDetector] detectFacesInImageView:_imageView completion:^(BOOL success) {
        NSLog(@"Face features %@", success ? @"detected!" : @"not detected!");
    }];
}

- (IBAction)eyesButtonAction:(UIButton *)sender {
    [self resetImageViewData];
    [[ACFaceDetector sharedDetector] detectEyesInImageView:_imageView completion:^(BOOL success) {
        NSLog(@"Face features %@", success ? @"detected!" : @"not detected!");
    }];
}

- (IBAction)effectButtonAction:(UIButton *)sender {
    [self resetImageViewData];
    
    [_effectButton setEnabled:NO];
    [[ACFaceDetector sharedDetector] makeBulgeEyesInImageView:_imageView completion:^(UIImage *image) {
        if (image) [_imageView setImage:image];
        [_effectButton setEnabled:YES];
    }];
}

@end
