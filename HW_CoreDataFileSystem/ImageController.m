//
//  ImageController.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "ImageController.h"

@interface ImageController () <UIScrollViewDelegate>

@end

@implementation ImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_imgData) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_imgData]];
        CGSize imgSize = [[imgView image] size];
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:imgView];
       
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:constraint];
        float aspect = imgSize.height/imgSize.width;
        
        constraint = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imgView attribute:NSLayoutAttributeWidth multiplier:aspect constant:0.0f];
        
        [imgView addConstraint:constraint];
    }
}


@end
