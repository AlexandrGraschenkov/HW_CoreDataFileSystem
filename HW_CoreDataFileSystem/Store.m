//
//  Store.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Store.h"

@implementation Store
- (Item*)rootItem {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", nil];
    NSArray* objects = [_managedObjectContext executeFetchRequest:request error:NULL];
    Item* rootItem = [objects lastObject];
    if (rootItem == nil) {
        rootItem = [Item insertItemWithTitle:@"Root" type:Folder parent:nil inManagedObjectContext:_managedObjectContext];
    }
    return rootItem;
}


@end
