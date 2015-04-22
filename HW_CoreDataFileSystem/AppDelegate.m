//
//  AppDelegate.m
//  HW_CoreDataFileSystem
//
//  Created by Alexander on 09.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) CoreDataManager *manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController* navigationController = (UINavigationController*) self.window.rootViewController;
    TableViewController* rootViewController = (TableViewController*)navigationController.topViewController;
    NSAssert([rootViewController isKindOfClass:[TableViewController class]], @"Should have an item view controller");
    _manager = [[CoreDataManager alloc] init];
    _store = [[Store alloc] init];
    _store.managedObjectContext = _manager.managedObjectContext;
    rootViewController.parent = self.store.rootItem;
    //application.applicationSupportsShakeToEdit = YES;
    return YES;
}

- (NSURL*)storeURL
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HW_CoreDataFileSystem.sqlite"];
    return storeURL;
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"HW_CoreDataFileSystem" withExtension:@"momd"];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([_store.managedObjectContext hasChanges])[_store.managedObjectContext save:NULL];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([_store.managedObjectContext hasChanges])[_store.managedObjectContext save:NULL];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end
