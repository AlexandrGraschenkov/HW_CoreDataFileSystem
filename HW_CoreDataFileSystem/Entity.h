//
//  Entity.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"

@class Entity;

typedef enum {
    Folder,
    Text,
    Picture
} FILETYPES;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * img;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *child;
@property (nonatomic, retain) Entity *parent;

- (NSFetchedResultsController*)childrenFetchedResultsController;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type text:(NSString*)text photo:(NSData*)data parent:(Entity*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type
                             parent:(Entity*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end