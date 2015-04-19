//
//  FetchedResults.h
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//
#import "SWCell.h"
@import Foundation;
@import CoreData;
@import UIKit;
#import "Item.h"
#import "CoreDataManager.h"

@class NSFetchedResultsController;

@protocol FetchedResultsDataDelegating

- (void)configureCell:(id)cell withObject:(id)object;
- (void)deleteObject:(id)object;
- (void)renameObject:(id)object to:(NSString*)str;
- (void)moveObject:(id)object to:(NSInteger)row;
-(void)showAlertFor:(UIAlertController*)alert;
@end

@interface FetchedResults : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<FetchedResultsDataDelegating> delegate;
@property (nonatomic, copy) NSString* reuseIdentifier;
@property (nonatomic) BOOL paused;

- (id)initWithTableView:(UITableView*)tableView;
- (id)selectedItem;
@end
