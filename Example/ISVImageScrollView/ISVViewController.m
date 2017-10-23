//
//  ISVViewController.m
//  ISVImageScrollView
//
//  Created by kupratsevich@gmail.com on 10/23/2017.
//  Copyright (c) 2017 kupratsevich@gmail.com. All rights reserved.
//

#import "ISVViewController.h"
#import "ISVImageScrollView.h"

@interface ISVViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ISVImageScrollView *imageScrollView;

@end

@implementation ISVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"Photo.jpg" inBundle:nil compatibleWithTraitCollection:nil];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageScrollView.imageView = self.imageView;
    self.imageScrollView.maximumZoomScale = 4.0;
    self.imageScrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
