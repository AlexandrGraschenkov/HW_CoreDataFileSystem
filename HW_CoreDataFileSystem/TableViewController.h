//
//  TableViewController.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Entity.h"
#import "Store.h"
#import "FetchedResults.h"
#import "TextController.h"
#import "ImageController.h"

@interface TableViewController : UITableViewController

@property (nonatomic, strong) Entity* parent;
-(unsigned long long)sizeOfFolder:(NSSet*)folder;
@end
