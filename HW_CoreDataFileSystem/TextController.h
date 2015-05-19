//
//  TextController.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entity.h"

@interface TextController : UIViewController
@property (nonatomic) IBOutlet UITextView *descript;
@property Entity *item;
@property NSString *theText;
@end
