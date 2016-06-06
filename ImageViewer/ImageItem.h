//
//  ImageItem.h
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

@import UIKit;

@interface ImageItem : NSObject

@property (nonatomic, copy) NSString  *title;
@property (nonatomic, copy) NSString  *imageDescription;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString  *imageURL;
@property (nonatomic) BOOL downloadInProgress;
@property (nonatomic) BOOL imageNotAvailable;

//Designated initialiser, |dictionary| is contains json element
- (id)initWithJSONJobject:(NSDictionary *)dictionary;

//Returns the height of the entire cell
- (NSInteger)calculatedCellHeight;

//When there is memory warning, purge the cashed images
- (void)cleanUp;
@end
