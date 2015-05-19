//
//  Store.m
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Store.h"

@implementation Store

- (Entity*)rootItem {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", nil];
    NSArray* objects = [_managedObjectContext executeFetchRequest:request error:NULL];
    Entity* rootItem = [objects lastObject];
    if (rootItem == nil) {
        rootItem = [Entity insertItemWithTitle:@"Root" type:Folder parent:nil inManagedObjectContext:_managedObjectContext];
    }
    return rootItem;
}


@end
