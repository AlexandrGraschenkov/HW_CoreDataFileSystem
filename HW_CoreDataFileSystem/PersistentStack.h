//
//  PersistentStack.h
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface PersistentStack : NSObject

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL;

@property (nonatomic,strong,readonly) NSManagedObjectContext* managedObjectContext;

@end
