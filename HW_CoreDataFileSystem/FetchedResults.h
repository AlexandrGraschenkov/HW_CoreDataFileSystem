//
//  FetchedResults.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "SWCell.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Entity.h"
#import "CoreDataManager.h"


@class NSFetchedResultsController;

@protocol FetchedResultsDataDelegating

- (void)configureCell:(id)cell withObject:(id)object;
- (void)deleteObject:(id)object;
- (void)renameObject:(id)object to:(NSString*)str;
-(void)showAlertFor:(UIAlertController*)alert;
@end

@interface FetchedResults : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *fetchedArray;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<FetchedResultsDataDelegating> delegate;
@property (nonatomic, copy) NSString* reuseIdentifier;
@property (nonatomic) BOOL paused;


- (id)initWithTableView:(UITableView*)tableView;
- (id)selectedItem;
@end
