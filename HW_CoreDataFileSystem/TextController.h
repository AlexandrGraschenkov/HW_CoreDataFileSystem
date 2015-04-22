//
//  TextController.h
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface TextController : UIViewController
@property (nonatomic) IBOutlet UITextView *descript;
@property Item *item;
@property NSString *theText;
@end
