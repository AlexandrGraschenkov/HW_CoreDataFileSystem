//
//  Store.h
//  HW_CoreDataFileSystem
//
//  Created by Михаил on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//
#import "Item.h"

@import Foundation;
@import CoreData;

@class Item;
@class NSFetchedResultsController;

@interface Store : NSObject

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
- (Item*)rootItem;

@end
