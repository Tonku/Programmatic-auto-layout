//
//  ImageItemCell.h
//  ImageViewer
//
//  Created by Tony Thomas on 08/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageItem.h"

//This is a custom tableview cell class.Which displays the
//title , image and description.
@interface ImageItemCell : UITableViewCell

//Set the content for the cell. |item| is the image item
- (void)setContent:(ImageItem *)item;

@end