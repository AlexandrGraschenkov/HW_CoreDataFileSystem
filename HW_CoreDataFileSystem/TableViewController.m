//
//  TableViewController.m
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
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

- (void)viewDidLoad {
    [super viewDidLoad];
    nCenter = [NSNotificationCenter defaultCenter];
    [self setupDataSource];
    [self setupAlertController];
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
    self.definesPresentationContext = YES;
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
                        [Entity insertItemWithTitle:newItemName type:Folder parent:_parent
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
                      [Entity insertItemWithTitle:newItemName type:Text text:@"" photo:[NSData data] parent:_parent inManagedObjectContext:[self managedObjectContext]];
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
    [Entity insertItemWithTitle:newItemName type:Picture text:nil photo:imageData parent:_parent inManagedObjectContext:[self managedObjectContext]];
    [[self managedObjectContext] save:NULL];
    newItemName=nil;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"%@", @"cancelled!");
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(int)sizeOfFolder:(NSSet*)folder{
    int whole=0;
    for (Entity *itm in folder) {
        if ([itm.type unsignedShortValue] == Folder) {
            whole += [self sizeOfFolder:itm.child];
        } else if ([itm.type unsignedShortValue] == Text) {
            whole += [[itm.text dataUsingEncoding:NSUTF8StringEncoding] length];
        } else if ([itm.type unsignedShortValue] == Picture){
            whole += [itm.img length];
        }
        
    }
    return whole;
}


- (void)configureCell:(id)theCell withObject:(id)object
{
    SWCell* cell = theCell;
    Entity* item = object;
    cell.label.text = item.title;
    
    NSString *temp;
    switch ([item.type unsignedShortValue]) {
        case Folder:
            cell.sizeLabel.text = [NSString stringWithFormat:@"Items: %lu Size: %@",(unsigned long)item.child.count,[NSByteCountFormatter stringFromByteCount:[self sizeOfFolder:item.child] countStyle:NSByteCountFormatterCountStyleFile]];
            [cell.image setImage:[UIImage imageNamed:@"folder_icon@2x"]];
            break;
        case Text:
            temp = [NSString stringWithFormat:@"Text size: %@",[NSByteCountFormatter stringFromByteCount:[[item.text dataUsingEncoding:NSUTF8StringEncoding] length] countStyle:NSByteCountFormatterCountStyleFile]];
            cell.sizeLabel.text = temp;
            [cell.image setImage:[UIImage imageNamed:@"text_file_icon@2x"]];
            break;
        case Picture:
            temp = [NSString stringWithFormat:@"Image size: %@",[NSByteCountFormatter stringFromByteCount:[item.img length] countStyle:NSByteCountFormatterCountStyleFile]];
            cell.sizeLabel.text = temp;
            [cell.image setImage:[UIImage imageNamed:@"photo_file_icon@2x"]];
            break;
        default:
            NSLog(@"ERROR type: %@", item.type);
            break;
    }
}


- (void)deleteObject:(id)object
{
    Entity* item = object;
    NSArray *childrens = [item.child allObjects];
    for (Entity *itm in childrens) {
        [[self managedObjectContext] deleteObject:itm];
    }
    [self.managedObjectContext deleteObject:item];
    [self.managedObjectContext save:nil];
}

- (void)renameObject:(id)object to:(NSString*)str
{
    Entity* item = object;
    [item setTitle:str];
    [item.managedObjectContext save:nil];
}


- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UINavigationController *nav = (UINavigationController*)self.presentedViewController;
    UIAlertController *alertController = (UIAlertController *)[nav visibleViewController];
    BOOL isExist=NO;
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        for (Entity *itm in [_fetchedResults fetchedArray]) {
            if ([itm.title isEqualToString:name.text])isExist=YES;
        }
        if ((name.text.length > 2) && !isExist) {
            NSLog(@"%@", @"not extsted");
            [alertController setTitle:@"New Item"];
            [folderAction setEnabled:YES];
            [textAction setEnabled:YES];
            [pictureAction setEnabled:YES];
        } else if ((name.text.length < 2) || isExist) {
            NSLog(@"%@", @"extsted");
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
    Entity* item = [_fetchedResults selectedItem];
    switch ([item.type unsignedShortValue]) {
        case Folder:{
            [self performSegueWithIdentifier:@"Folder" sender:self];
            break;
        }
        case Text:{
            TextController *text = (TextController*)[self.storyboard instantiateViewControllerWithIdentifier:@"textV"];
            text.theText = item.text;
            text.item = item;
            [self.navigationController pushViewController:text animated:YES];
            break;
        }
        case Picture:{
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
    Entity* item = [_fetchedResults selectedItem];
    subItemViewController.parent = item;
}

- (void)setParent:(Entity*)parent
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
