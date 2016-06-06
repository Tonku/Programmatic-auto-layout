//
//  ImageViewModel.h
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadImage.h"
#import "ImageItem.h"

//This protocol notifies the delegate about change in model
//which will trigger a UI update
@protocol ImageViewModelDelegate<NSObject>

//Tells the delegate to update a row because, there is a change in
//the model object corresponding to the row at the specified index path
- (void)updateRowAtIndexPath:(NSIndexPath *)indexPath;
//Informs that there is an update for the model, along with its title
- (void)modelUpdatedWithTitle:(NSString *)title;

@end

@interface ImageViewModel : NSObject<DownloadImageDelegate>

//designated initialiser set the |imageViewModelDelegate| is ImageViewModelDelegate
- (id)initWithDelegate:(id) imageViewModelDelegate;

//This will return height for a row at index path
- (CGFloat)heightForRowAtIndexPath :(NSIndexPath *)indexPath;

//This method will return a model object (ImageItem) which respresnts the content of
//a table view cell.
- (ImageItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

//Optimise the image download, only get the images in currently |visibleRows|
//all the pending downlads in non visible cells are cancelled.
- (void)optimisedImageDownloadWithVisibleRows:(NSSet *)visibleRows;

//Cancel all downloads if the user navigate out of the page or there is a memmory warning
- (void)cancellAllDownloads;

//Returns the total number of objects in the model collection , which will become the
//number of rows in tableview
- (NSInteger)itemCount;

//Clean up the memory when there is memory warning
- (void)cleanupMemory;

//Suspend all image downloads
- (void)suspendAllDownloads;

//Resume all image downloads
- (void)resumeAllDownloads;

@end
