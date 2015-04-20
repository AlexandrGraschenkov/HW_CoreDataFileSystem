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
    NSString *newItemName;
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
}

#pragma mark -
#pragma mark Search Bar


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
    [_fetchedResults setContext:[self managedObjectContext]];
    _fetchedResults.delegate = self;
    _fetchedResults.reuseIdentifier = @"Cell";
}


-(void)setupAlertController{
    addItem = [UIAlertController alertControllerWithTitle:@"New Item" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                        newItemName = [addItem.textFields.lastObject text];
                        [Item insertItemWithTitle:newItemName type:Folder parent:_parent
                           inManagedObjectContext:[self managedObjectContext]];
                        newItemName=nil;
                        [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                         object:nil];
                        [addItem dismissViewControllerAnimated:YES completion:nil];
                    }];
    textAction = [UIAlertAction
                  actionWithTitle:@"Text"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *action)
                  {
                      newItemName = [addItem.textFields.lastObject text];
                      [Item insertItemWithTitle:newItemName type:Text text:@"" photo:[NSData data] parent:_parent inManagedObjectContext:[self managedObjectContext]];
                      newItemName=nil;
                      [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                       object:nil];
                      [addItem dismissViewControllerAnimated:YES completion:nil];
                  }];
    pictureAction = [UIAlertAction
                     actionWithTitle:@"Picture"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction *action)
                     {
                         newItemName = [addItem.textFields.lastObject text];
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
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [Item insertItemWithTitle:newItemName type:Picture text:nil photo:imageData parent:_parent inManagedObjectContext:[self managedObjectContext]];
    [[self managedObjectContext] save:NULL];
    newItemName=nil;
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

- (void)deleteObject:(id)object
{
    Item* item = object;
    NSArray *childrens = [item.children allObjects];
    for (Item *itm in childrens) {
        [[self managedObjectContext] deleteObject:itm];
    }
//    [item.managedObjectContext deleteObject:item];
//    [item.managedObjectContext save:nil];
    [self.managedObjectContext deleteObject:item];
    [self.managedObjectContext save:nil];
}

- (void)renameObject:(id)object to:(NSString*)str
{
    Item* item = object;
    [item setTitle:str];
    [item.managedObjectContext save:nil];
}


- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UINavigationController *nav = self.presentedViewController;
    UIAlertController *alertController = (UIAlertController *)[nav visibleViewController];
    BOOL isExist=NO;
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        for (Item *itm in [_fetchedResults fetchedArray]) {
            if ([itm.title isEqualToString:name.text])isExist=YES;
        }
        if ((name.text.length > 2) && !isExist) {
            [alertController setTitle:@"New Item"];
            [folderAction setEnabled:YES];
            [textAction setEnabled:YES];
            [pictureAction setEnabled:YES];
        } else if ((name.text.length < 2) || isExist) {
            alertController.title = (isExist) ? @"Is Exist!" : @"Too short!";
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
    NSLog(@"ORDER!!!: %@", item.order);
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

- (void)dealloc
{
    [nCenter removeObserver:self];
}



@end
