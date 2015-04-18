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
        [_imgView setImage:[UIImage imageWithData:_imgData]];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
}


@end
