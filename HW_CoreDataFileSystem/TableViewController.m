//
//  TableViewController.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 18.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <FetchedResultsDataDelegating, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIAlertController *addItem;
    NSNotificationCenter *nCenter;
    UIAlertAction *cancelAct;
    UIAlertAction *folderAction;
    UIAlertAction *textAction;
    UIAlertAction *pictureAction;
    NSString *tempName;
    
}

@property (nonatomic,strong) FetchedResults *fetchedResults;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusButton;
@property(nonatomic,retain) UIPopoverPresentationController *popover;
@end

@implementation TableViewController

#pragma mark - General

- (void)viewDidLoad {
    [super viewDidLoad];
    nCenter = [NSNotificationCenter defaultCenter];
    [self setupDataSource];
    [self setupAlertController];
//    
//    NSLog(@"View Width: %f Height: %f", self.view.frame.size.width,self.view.frame.size.height);
//    NSLog(@"%@", @"----------------------------");
//    NSLog(@"NavBar Width: %f Height: %f", self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _fetchedResults.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _fetchedResults.paused = YES;
}

- (NSManagedObjectContext*)managedObjectContext
{
    return _parent.managedObjectContext;
}

-(void)setupDataSource{
    _fetchedResults = [[FetchedResults alloc] initWithTableView:self.tableView];
    _fetchedResults.fetchedResultsController = _parent.childrenFetchedResultsController;
    _fetchedResults.delegate = self;
    _fetchedResults.reuseIdentifier = @"Cell";
}
-(void)setupAlertController{
    addItem = [UIAlertController alertControllerWithTitle:@"" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    cancelAct = [UIAlertAction
                 actionWithTitle:@"Cancel"
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction *action)
                 {
                     [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                      object:nil];
                     [addItem dismissViewControllerAnimated:YES completion:nil];
                 }];
    
    folderAction = [UIAlertAction
                    actionWithTitle:@"Folder"
                    style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action)
                    {
                        UITextField *textField = addItem.textFields.lastObject;
                        NSString *name = textField.text;
                        NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"add item \"%@\"", @"Undo action name of add item"), name];
                        [self.undoManager setActionName:actionName];
                        [Item insertItemWithTitle:name type:Folder parent:_parent
                           inManagedObjectContext:[self managedObjectContext]];
                        [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                         object:nil];
                        [addItem dismissViewControllerAnimated:YES completion:nil];
                    }];
    textAction = [UIAlertAction
                  actionWithTitle:@"Text"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *action)
                  {
                      UITextField *textField = addItem.textFields.lastObject;
                      NSString *name = textField.text;
                      NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"add item \"%@\"", @"Undo action name of add item"), name];
                      [self.undoManager setActionName:actionName];
                      [Item insertItemWithTitle:name type:Text text:@"" photo:nil parent:_parent inManagedObjectContext:[self managedObjectContext]];
                      [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                       object:nil];
                      [addItem dismissViewControllerAnimated:YES completion:nil];
                  }];
    pictureAction = [UIAlertAction
                     actionWithTitle:@"Picture"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction *action)
                     {
                         UITextField *textField = addItem.textFields.lastObject;
                         NSString *name = textField.text;
                         NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"add item \"%@\"", @"Undo action name of add item"), name];
                         [self.undoManager setActionName:actionName];
                         tempName = name;
                         [Item insertItemWithTitle:name type:Picture text:nil photo:[NSData data] parent:_parent inManagedObjectContext:[self managedObjectContext]];
                         [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                          object:nil];
                         [addItem dismissViewControllerAnimated:YES completion:nil];
                         [self selectPhoto];
                     }];
    [addItem addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"filename...";
        [nCenter addObserver:self
                    selector:@selector(alertTextFieldDidChange:)
                        name:UITextFieldTextDidChangeNotification
                      object:textField];
    }];
    folderAction.enabled = NO;
    textAction.enabled = NO;
    pictureAction.enabled = NO;
    [addItem addAction:cancelAct];
    [addItem addAction:folderAction];
    [addItem addAction:textAction];
    [addItem addAction:pictureAction];

}

- (IBAction)plusPressed:(UIBarButtonItem *)sender {
    [addItem.view setAlpha:0];
    [addItem.view setOpaque:NO];
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:addItem];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    _popover = destNav.popoverPresentationController;
    _popover.delegate = self;
    if (sender) {
        _popover.barButtonItem = sender;
    } else  _popover.barButtonItem = _plusButton;
    destNav.navigationBarHidden = YES;
    [self presentViewController:destNav animated:YES completion:^{
        [UIView animateWithDuration:0.5 animations:^{
            [addItem.view setAlpha:1.0];
            [addItem.view setOpaque:YES];
        }];
    }];
    
}

- (void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}


#pragma mark - Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    request.predicate =[NSPredicate predicateWithFormat:@"title = %@", tempName];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    Item *tempItem = [results lastObject];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
    
    tempItem.img = imageData;
    [tempItem.managedObjectContext save:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    tempName=nil;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"%@", @"cancelled!");
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(unsigned long long)sizeOfFolder:(NSSet*)folder{
    unsigned long long whole=0;
    for (Item *itm in folder) {
        if ([itm.type unsignedShortValue]==1) {
            whole += [self sizeOfFolder:itm.children];
        } else if ([itm.type unsignedShortValue]==2) {
            whole += [[itm.text dataUsingEncoding:NSUTF8StringEncoding] length];
        } else if ([itm.type unsignedShortValue]==3){
            whole += [itm.img length];
        }
        
    }
    return whole;
}

- (void)configureCell:(id)theCell withObject:(id)object
{
    SWCell* cell = theCell;
    Item* item = object;
    cell.label.text = item.title;
    NSString *temp;
    switch ([item.type unsignedShortValue]) {
        case 1:
            cell.sizeLabel.text = [NSString stringWithFormat:@"Items: %lu Size: %@",(unsigned long)item.children.count,[NSByteCountFormatter stringFromByteCount:[self sizeOfFolder:item.children] countStyle:NSByteCountFormatterCountStyleFile]];
            [cell.image setImage:[UIImage imageNamed:@"folder"]];
            break;
        case 2:
            temp = [NSString stringWithFormat:@"Text size: %@",[NSByteCountFormatter stringFromByteCount:[[item.text dataUsingEncoding:NSUTF8StringEncoding] length] countStyle:NSByteCountFormatterCountStyleFile]];
            cell.sizeLabel.text = temp;
            [cell.image setImage:[UIImage imageNamed:@"text"]];
            break;
        case 3:
            temp = [NSString stringWithFormat:@"Image size: %@",[NSByteCountFormatter stringFromByteCount:[item.img length] countStyle:NSByteCountFormatterCountStyleFile]];
            cell.sizeLabel.text = temp;
            [cell.image setImage:[UIImage imageNamed:@"picture"]];
            break;
        default:
            NSLog(@"ERROR type: %@", item.type);
            break;
    }
}

- (void)moveObject:(id)object to:(NSInteger)row
{
    Item* item = object;
    NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"Move \"%@\"", @"Move undo action name"), item.title];
    [self.undoManager setActionName:actionName];
    [item.managedObjectContext save:nil];

}

- (void)deleteObject:(id)object
{
    Item* item = object;
    NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"", @"Delete undo action name"), item.title];
    [self.undoManager setActionName:actionName];
    [item.managedObjectContext deleteObject:item];
    [item.managedObjectContext save:nil];
}

- (void)renameObject:(id)object to:(NSString*)str
{
    Item* item = object;
    NSString* actionName = [NSString stringWithFormat:NSLocalizedString(@"Rename \"%@\"", @"Rename undo action name"), item.title];
    [self.undoManager setActionName:actionName];
    [item setTitle:str];
    [item.managedObjectContext save:nil];
}


- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UINavigationController *nav = self.presentedViewController;
    UIAlertController *alertController = (UIAlertController *)[nav visibleViewController];
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        if (name.text.length > 2) {
            [folderAction setEnabled:YES];
            [textAction setEnabled:YES];
            [pictureAction setEnabled:YES];
        } else {
            [folderAction setEnabled:NO];
            [textAction setEnabled:NO];
            [pictureAction setEnabled:NO];
        }
    }
}

-(void)showAlertFor:(UIAlertController*)alert{
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Item* item = [_fetchedResults selectedItem];
    switch ([item.type unsignedShortValue]) {
        case 1:{
            [self performSegueWithIdentifier:@"Folder" sender:self];
            break;
        }
        case 2:{
            TextController *text = (TextController*)[self.storyboard instantiateViewControllerWithIdentifier:@"textV"];
            text.theText = item.text;
            text.item = item;
            [self.navigationController pushViewController:text animated:YES];
            break;
        }
        case 3:{
            ImageController *image = (ImageController*)[self.storyboard instantiateViewControllerWithIdentifier:@"imageV"];
            image.imgData = item.img;
            [self.navigationController pushViewController:image animated:YES];
            break;
        }
        default:
            NSLog(@"ERROR type: %@", item.type);
            break;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@", @"SEGUE!!");
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"Folder"]) {
        [self presentSubItemViewController:segue.destinationViewController];
    }
}

- (void)presentSubItemViewController:(TableViewController*)subItemViewController
{
    Item* item = [_fetchedResults selectedItem];
    subItemViewController.parent = item;
}

- (void)setParent:(Item*)parent
{
    _parent = parent;
    self.navigationItem.title = parent.title;
}



- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSUndoManager*)undoManager
{
    return self.managedObjectContext.undoManager;
}

- (void)dealloc
{
    [nCenter removeObserver:self];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



@end
