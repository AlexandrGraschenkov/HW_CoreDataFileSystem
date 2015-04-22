//
//  CoreDataManager.m
//  Test_CoreData
//
//  Created by Alexander on 18.03.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager{
    NSMutableDictionary *dic;
    dispatch_queue_t queue;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)shared
{
    static id _singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}
-(instancetype)init{
    self = [super init];
    queue = dispatch_queue_create("CoreData queue", DISPATCH_QUEUE_SERIAL);
    _managedObjectModel = [self managedObjectModel];
    _persistentStoreCoordinator = [self persistentStoreCoordinator];
    _managedObjectContext = [self managedObjectContext];
    return self;
}

//-(void)saveItem:(Item*)item{
//    dispatch_async(queue, ^{
//        [_managedObjectContext insertObject:item];
//    });
//}
//-(void)deleteItem:(Item*)item{
//    dispatch_async(queue, ^{
//        [_managedObjectContext deleteObject:item];
//    });
//}
-(void)save{
    dispatch_async(queue, ^{
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"%@", @"ABORTED!");
            abort();
        }
    });
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HW_CoreDataFileSystem" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *appDirectiory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [appDirectiory URLByAppendingPathComponent:@"HW_CoreDataFileSystem.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {

    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    _managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    return _managedObjectContext;
}


- (NSManagedObjectContext *)getContextForCurrentQueue {
    if ([NSThread isMainThread]) {
        return [self managedObjectContext];
    } else {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        NSManagedObjectContext *moc = [threadDict objectForKey:@"moc_key"];
        
        if (moc == nil) {
            moc = [[NSManagedObjectContext alloc] init];
            [moc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
            [threadDict setObject:moc forKey:@"moc_key"];
        }
        return moc;
    }
}

@end
