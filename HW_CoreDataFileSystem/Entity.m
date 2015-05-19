//
//  Entity.m
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Entity.h"

@implementation Entity

@dynamic title;
@dynamic text;
@dynamic img;
@dynamic type;
@dynamic order;
@dynamic child;
@dynamic parent;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type
                             parent:(Entity*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSUInteger order = parent.numberOfChildren;
    Entity* item = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                                 inManagedObjectContext:managedObjectContext];
    item.title = title;
    item.parent = parent;
    item.order = @(order);
    item.type = [NSNumber numberWithShort:type];
    [[CoreDataManager shared] save];
    return item;
}

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type text:(NSString*)text photo:(NSData*)data parent:(Entity*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSUInteger order = parent.numberOfChildren;
    Entity* item = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                               inManagedObjectContext:managedObjectContext];
    item.title = title;
    item.parent = parent;
    item.order = @(order);
    item.type = [NSNumber numberWithShort:type];
    item.text = text;
    item.img = data;
    [[CoreDataManager shared] save];
    return item;
}

+ (NSString*)entityName
{
    return @"Entity";
}

- (NSUInteger)numberOfChildren
{
    return self.child.count;
}

- (NSFetchedResultsController*)childrenFetchedResultsController
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", self];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)prepareForDeletion
{
    if (self.parent.isDeleted) return;
    
    NSSet* siblings = self.parent.child;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"order > %@", self.order];
    NSSet* itemsAfterSelf = [siblings filteredSetUsingPredicate:predicate];
    [itemsAfterSelf enumerateObjectsUsingBlock:^(Entity* sibling, BOOL* stop)
     {
         sibling.order = @(sibling.order.integerValue - 1);
     }];
}

@end