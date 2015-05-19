//
//  ImageController.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property NSData *imgData;
@end
