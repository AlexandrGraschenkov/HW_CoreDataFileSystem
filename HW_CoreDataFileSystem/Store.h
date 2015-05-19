//
//  Store.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Entity.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity;
@class NSFetchedResultsController;

@interface Store : NSObject

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
- (Entity*)rootItem;

@end
