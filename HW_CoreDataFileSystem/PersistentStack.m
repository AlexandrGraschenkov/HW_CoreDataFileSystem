//
//  PersistentStack.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "PersistentStack.h"

@interface PersistentStack ()

@property (nonatomic,strong,readwrite) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSURL* modelURL;
@property (nonatomic,strong) NSURL* storeURL;

@end

@implementation PersistentStack

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
{
    self = [super init];
    if (self) {
        _storeURL = storeURL;
        _modelURL = modelURL;
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)setupManagedObjectContext
{
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    [_managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:nil error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    _managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:_modelURL];
}


@end
