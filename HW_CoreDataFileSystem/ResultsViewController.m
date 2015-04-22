//
//  ResultsViewController.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 22.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Item *item = [_searchResults objectAtIndex:indexPath.row];
    SWCell *cell = (SWCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
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

    return cell;
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



@end
