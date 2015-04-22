//
//  TableViewController.h
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "Item.h"
#import "Store.h"
#import "FetchedResults.h"
#import "TextController.h"
#import "ImageController.h"

@interface TableViewController : UITableViewController

@property (nonatomic, strong) Item* parent;
-(unsigned long long)sizeOfFolder:(NSSet*)folder;
@end
