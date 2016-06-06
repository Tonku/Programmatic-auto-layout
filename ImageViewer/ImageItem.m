//
//  ImageItem.m
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import "ImageItem.h"
#include "Constants.h"

@interface ImageItem()

@property (nonatomic)   NSInteger cellHeightInVerticalOrientation;


@end

@implementation ImageItem

//initiliser does the translation of JOSN dictionary to
//the model object.
- (id)initWithJSONJobject:(NSDictionary *)dictionary{
  self = [super init];
  id value = [dictionary objectForKey:@"title"];
  //Dictioary handles null value using NSNull so check it
  if (value!=[NSNull null]) {
    self.title = value;
  }
  else{
    self.title = @"Untitled";
  }
  value = [dictionary objectForKey:@"description"];
  if(value!=[NSNull null]) {
    self.imageDescription = value;
  }
  else{
    self.imageDescription = @"No Description";
  }
  value = [dictionary objectForKey:@"imageHref"];
  if (value!=[NSNull null]) {
    self.imageURL = value;
  }
  else{
    self.imageURL = nil;
  }
  //Estimate the cell height in portrait mode,Lanscpe mode is
  //beyond the scope of this app.
  //we only need to take into account of the description
  //label.All other UI elements are kept fixed.Calculation is in
  //background thread to prevent main thread from chocking.
  //This will lead to a more fluid interface
  CGRect rect = [UIScreen mainScreen].bounds;
  NSInteger widthInPortraitMode = rect.size.width;
  NSInteger constantHeight = kImageHeight+kTitleHeight+kLabelMargin;
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kFontSize]};
  //This api calculate the size of a text when it rendered in a specific width using
  //a specified font, and this is the heart of this implemention , which support ios7
  //in iOS8 auto resizing tableview cell is very simple
  rect = [self.imageDescription boundingRectWithSize:CGSizeMake(widthInPortraitMode, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
  self.cellHeightInVerticalOrientation = rect.size.height+constantHeight;
  return self;
}

-(NSInteger)calculatedCellHeight{
  return self.cellHeightInVerticalOrientation;
}

- (void)cleanUp{
  
  self.image = nil;
}
@end
