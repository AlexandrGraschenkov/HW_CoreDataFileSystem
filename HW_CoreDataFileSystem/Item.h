//
//  Item.h
//  HW_CoreDataFileSystem
//
//  Created by Михаил on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "CoreDataManager.h"

@class Item;
typedef enum {
    Folder=1,
    Text=2,
    Picture=3
} FILETYPES;
@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * img;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Item *parent;

- (NSFetchedResultsController*)childrenFetchedResultsController;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type text:(NSString*)text photo:(NSData*)data parent:(Item*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type
                             parent:(Item*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

