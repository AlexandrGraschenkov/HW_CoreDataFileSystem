//
//  AppDelegate.h
//  HW_CoreDataFileSystem
//
//  Created by Alexander on 09.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//
@import UIKit;
@import CoreData;
#import "CoreDataManager.h"
#import "TableViewController.h"
#import "Store.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//
//- (void)saveContext;



@end

