//
//  FetchedResults.m
//  HW_CoreDataFileSystem
//
//  Created by Михаил on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "FetchedResults.h"
@interface FetchedResults(){
    UIAlertController *renameItem;
    UIAlertAction *cancelAct;
    UIAlertAction *yesAction;
    NSNotificationCenter *nCenter;
    UILongPressGestureRecognizer *longPress;
    NSArray *scopeButtonTitles;
    BOOL isMoving;
    BOOL scopeButtonPressedIndexNumber;
}
@property (nonatomic, strong) UITableView* table;

@end

@implementation FetchedResults

- (id)initWithTableView:(UITableView*)tableView
{
    self = [super init];
    if (self) {
        _table = tableView;
        _table.dataSource = self;
        nCenter = [NSNotificationCenter defaultCenter];
        [self setupSearching];
        [self setupLongPressRecognizer];
    }
    return self;
}


#pragma mark - Searching!

-(void)setupSearching{
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [_searchController setSearchResultsUpdater:self];
    [[_searchController searchBar] sizeToFit];
    
    scopeButtonTitles = [[NSArray alloc] initWithObjects:@"All",@"Folders",@"Text",@"Pics", nil];
    [[_searchController searchBar] setScopeButtonTitles:scopeButtonTitles];
    
    _table.tableHeaderView = self.searchController.searchBar;
    [_searchController setDimsBackgroundDuringPresentation:NO];
    [_searchController setDelegate:self];
    [_searchController searchBar].enablesReturnKeyAutomatically = NO;
    [[_searchController searchBar] setDelegate:self];
    [_searchController searchBar].text = @" ";
    
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.searchController = searchController;
    NSNumber *selectedScopeButtonIndex = [NSNumber numberWithUnsignedShort:
                                          [searchController.searchBar selectedScopeButtonIndex]];
    
    NSString *searchString = [searchController.searchBar text];
    [self updateFilteredContentForName:searchString andType:selectedScopeButtonIndex];
    [_table reloadData];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length < 1) {
        searchBar.text = @" ";
    }
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchBar.text = @" ";
    return YES;
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL isPreviousTextDummyString = [searchBar.text isEqualToString:@" "];
    BOOL isNewTextDummyString = [text isEqualToString:@" "];
    if (isPreviousTextDummyString && !isNewTextDummyString && text.length > 0) {
        searchBar.text = @"";
    }
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [[_searchController searchResultsUpdater] updateSearchResultsForSearchController:_searchController];
}

-(void)updateFilteredContentForName:(NSString*)name andType:(NSNumber*)type{
    NSPredicate *typePredicate;
    typePredicate = [NSPredicate predicateWithFormat:@"type == %d", [type intValue]];
    if ([name isEqualToString:@" "]) {
        if ([type isEqualToNumber:[NSNumber numberWithInt:0]]) {
            if (![_searchArray isEqualToArray:_fetchedArray]) {
                _searchArray = [_fetchedArray mutableCopy];
            }
        } else {
            _searchArray = [NSMutableArray arrayWithArray:
                            [_fetchedArray filteredArrayUsingPredicate:typePredicate]];
        }
    } else {
        [_searchArray removeAllObjects];
        
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", name];
        NSArray *preds = [NSArray arrayWithObjects:namePredicate,typePredicate, nil];
        NSPredicate *allPreds = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
        if ([type intValue]==0) {
            _searchArray = [NSMutableArray arrayWithArray:
                            [_fetchedArray filteredArrayUsingPredicate:namePredicate]];
        } else {
            _searchArray = [NSMutableArray arrayWithArray:
                            [_fetchedArray filteredArrayUsingPredicate:allPreds]];
        }
    }
}


#pragma mark - UIGestureRecognizerDelegate

-(void)setupLongPressRecognizer{
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPress.delegate = self;
    [_table addGestureRecognizer:longPress];
    isMoving = NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (![otherGestureRecognizer isEqual:longPress]) {
        [otherGestureRecognizer shouldBeRequiredToFailByGestureRecognizer:longPress];
    }
    return YES;
}


#pragma mark - Cell movement

-(IBAction)onLongPress:(id)sender{
    if (_searchController.isActive) return;
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:_table];
    NSIndexPath *indexPath = [_table indexPathForRowAtPoint:location];
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                [_table setScrollEnabled:NO];
                sourceIndexPath = indexPath;
                SWCell *cell = (SWCell*)[_table cellForRowAtIndexPath:indexPath];
                snapshot = [self customSnapshotFromView:cell];
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_table addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    snapshot.alpha = 1;
                    cell.alpha = 0.0;
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                isMoving = YES;
                [_fetchedArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [_fetchedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Item *itm = (Item*)obj;
                    itm.order = [NSNumber numberWithInteger:idx];
                }];
                [_table moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            SWCell *cell = (SWCell*)[_table cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            
            
            if ([[_fetchedResultsController managedObjectContext] hasChanges]) {
                [[_fetchedResultsController managedObjectContext] save:nil];
            }
            [_table setScrollEnabled:YES];
            isMoving=NO;
            break;
        }
            
    }
    
}

- (UIView *)customSnapshotFromView:(UIView *)inputView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    if (_searchController.isActive) return 1;
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_searchController.isActive) return [_searchArray count];
    id<NSFetchedResultsSectionInfo> section = _fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    id object = nil;
    SWCell *cell = (SWCell *)[tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    if (_searchController.isActive) {
        object = [_searchArray objectAtIndex:indexPath.row];
        cell.delegate = nil;
        cell.leftUtilityButtons = nil;
    } else {
        cell.leftUtilityButtons = [self leftButtons];
        cell.delegate = self;
        object = [_fetchedResultsController objectAtIndexPath:indexPath];
    }
    [_delegate configureCell:cell withObject:object];
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    if (_searchController.isActive) return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - SWLeftButton

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0] title:@"Rename"];
    return leftUtilityButtons;
}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    if (_searchController.isActive) return;
    NSLog(@"%@", @"Rename");
    SWCell *myCell = (SWCell*)cell;
    
    renameItem = [UIAlertController alertControllerWithTitle:@"" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    cancelAct = [UIAlertAction
                 actionWithTitle:@"Cancel"
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction *action)
                 {
                     [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                      object:nil];
                     [renameItem dismissViewControllerAnimated:YES completion:nil];
                     [cell hideUtilityButtonsAnimated:YES];
                 }];
    
    yesAction = [UIAlertAction
                 actionWithTitle:@"Accept"
                 style:UIAlertActionStyleDefault
                 handler:^(UIAlertAction *action)
                 {
                     UITextField *textField = renameItem.textFields.lastObject;
                     NSString *name = textField.text;
                     for (Item *obj in [_fetchedResultsController fetchedObjects]) {
                         if ([obj.title isEqualToString:[myCell.label text]]) {
                             [_delegate renameObject:obj to:name];
                         }
                     }
                     [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                      object:nil];
                     [renameItem dismissViewControllerAnimated:YES completion:nil];
                 }];
    [renameItem addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"filename...";
        [nCenter addObserver:self
                    selector:@selector(alertTextFieldDidChange:)
                        name:UITextFieldTextDidChangeNotification
                      object:textField];
    }];
    yesAction.enabled = NO;
    [renameItem addAction:cancelAct];
    [renameItem addAction:yesAction];
    [_delegate showAlertFor:renameItem];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UIAlertController *alertController = renameItem;
    BOOL isExist = NO;
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        
        for (Item *itm in [self fetchedArray]) {
            if ([itm.title isEqualToString:name.text])isExist=YES;
        }

        if ((name.text.length > 2) && !isExist){
            [yesAction setEnabled:YES];
        } else if ((name.text.length < 2) || isExist){
            [yesAction setEnabled:NO];
        }
    }
}


#pragma mark NSFetchedResultsControllerDelegate


- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
    if (isMoving)return;
    [_table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
    if (isMoving)return;
    [_table endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    if (isMoving || _searchController.isActive)return;
    
    if (type == NSFetchedResultsChangeInsert) {
        [_table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        [_table moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeUpdate) {
        [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else NSAssert(NO,@"");
    
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    //NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
    _fetchedArray = [[NSMutableArray alloc] initWithArray:[_fetchedResultsController fetchedObjects]];
    _searchArray = [[NSMutableArray alloc] initWithCapacity:[_fetchedArray count]];
}


- (id)selectedItem {
    NSIndexPath* path = _table.indexPathForSelectedRow;
    if (_searchController.isActive) {
        return path ? [_searchArray objectAtIndex:path.row] : nil;
    } else {
        return path ? [_fetchedResultsController objectAtIndexPath:path] : nil;
    }
}


- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        _fetchedResultsController.delegate = nil;
    } else {
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:NULL];
        [_table reloadData];
        _fetchedArray = [[NSMutableArray alloc] initWithArray:[_fetchedResultsController fetchedObjects]];
        
    }
}



#pragma mark Content Filtering




@end
