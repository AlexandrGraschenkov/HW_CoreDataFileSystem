//
//  TextController.m
//  HW_CoreDataFileSystem
//
//  Created by Михаил on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "TextController.h"

@interface TextController ()

@end

@implementation TextController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_theText) {
        [_descript setContentMode:UIViewContentModeScaleToFill];
        [_descript setText:_theText];
    }
}

-(void)dealloc{
    _item.text = _descript.text;
    [[_item managedObjectContext] save:nil];
}

@end
