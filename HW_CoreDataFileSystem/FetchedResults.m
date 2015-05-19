//
//  FetchedResults.m
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
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
        [self setupLongPressRecognizer];
    }
    return self;
}

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

-(IBAction)onLongPress:(id)sender{
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
                    Entity *itm = (Entity*)obj;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    id<NSFetchedResultsSectionInfo> section = _fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    id object = nil;
    SWCell *cell = (SWCell *)[tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    object = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    [_delegate configureCell:cell withObject:object];
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
}


- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0] title:@"Rename"];
    return leftUtilityButtons;
}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
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
                     for (Entity *obj in [_fetchedResultsController fetchedObjects]) {
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
        
        for (Entity *itm in [self fetchedArray]) {
            if ([itm.title isEqualToString:name.text])isExist=YES;
        }
        
        if ((name.text.length > 2) && !isExist){
            [yesAction setEnabled:YES];
        } else if ((name.text.length < 2) || isExist){
            [yesAction setEnabled:NO];
        }
    }
}


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
    if (isMoving)return;
    
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
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
    _fetchedArray = [[NSMutableArray alloc] initWithArray:[_fetchedResultsController fetchedObjects]];
}


- (id)selectedItem {
    NSIndexPath* path = _table.indexPathForSelectedRow;
    return path ? [_fetchedResultsController objectAtIndexPath:path] : nil;
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


@end
