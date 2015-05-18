//
//  CoreDataManager.h
//  Test_CoreData
//
//  Created by Alexander on 18.03.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

@import Foundation;
@import CoreData;
@class Item;

@interface CoreDataManager : NSObject

+ (instancetype)shared;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectContext *)getContextForCurrentQueue;
-(void)save;
@end
