//
//  SWCell.h
//  HW_CoreDataFileSystem
//
//  Created by Евгений Сергеев on 19.05.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "SWTableViewCell.h"

@interface SWCell : SWTableViewCell


@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
