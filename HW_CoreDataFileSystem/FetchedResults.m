//
//  FetchedResults.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "FetchedResults.h"
@interface FetchedResults(){
    UIAlertController *renameItem;
    UIAlertAction *cancelAct;
    UIAlertAction *yesAction;
    NSNotificationCenter *nCenter;
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
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    id<NSFetchedResultsSectionInfo> section = _fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [_fetchedResultsController objectAtIndexPath:indexPath];
    SWCell *cell = (SWCell *)[tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    [_delegate configureCell:cell withObject:object];
    return cell;
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
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        if (name.text.length > 2)[yesAction setEnabled:YES];
        if (name.text.length < 2)[yesAction setEnabled:NO];
    }
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
}


#pragma mark NSFetchedResultsControllerDelegate



- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [_table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [_table endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [_table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        [_table moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeUpdate) {
        [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSAssert(NO,@"");
    }
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
}


- (id)selectedItem
{
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
    }
}


@end
