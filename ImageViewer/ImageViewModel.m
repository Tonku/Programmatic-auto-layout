//
//  ImageViewModel.m
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import "ImageViewModel.h"
#import "ImageItem.h"
#import "ImageViewModel.h"
#import "NSDictionary_JSONExtensions.h"

@interface ImageViewModel(){
}
@property (nonatomic, strong) NSMutableArray *imageList;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;

@end

@implementation ImageViewModel

- (id)initWithDelegate:(id) imageViewModelDelegate{
  self = [super init];
  self.delegate = imageViewModelDelegate;
  [self populateImageList];
  self.operationQueue = [[NSOperationQueue alloc]init];
  self.operationQueue.maxConcurrentOperationCount = 5;
  return self;
}

- (void)populateImageList{
  NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
  NSURLSessionDownloadTask *jsonTask =
  [[NSURLSession sharedSession] downloadTaskWithURL:url
                                  completionHandler:^(NSURL * _Nullable location,
                                                      NSURLResponse * _Nullable response,
                                                      NSError * _Nullable error) {
                                    if (error) {
                                      return;
                                    }
                                    NSString *theJSONString = [[NSString alloc]initWithContentsOfURL:location
                                                                                            encoding:NSASCIIStringEncoding
                                                                                               error:&error];
                                    NSError *theError = NULL;
                                    NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:theJSONString
                                                                                                  error:&theError];
                                    //populate the image items
                                    self.imageList = [[NSMutableArray alloc]init];
                                    NSArray *items  = [responseDict objectForKey:@"rows"];
                                    for(NSDictionary *item in items) {
                                      
                                      ImageItem *imageItem = [[ImageItem alloc]initWithJSONJobject:item];
                                      [self.imageList addObject:imageItem];
                                    }
                                    //call the delegate to tell its time to update the UI, because the model
                                    //is ready
                                    NSString *title = [responseDict objectForKey:@"title"];
                                    if ([self.delegate respondsToSelector:@selector(modelUpdatedWithTitle:)]) {
                                       [self.delegate modelUpdatedWithTitle:title];
                                    }
                                  }];
   [jsonTask resume];
}

- (CGFloat)heightForRowAtIndexPath :(NSIndexPath *)indexPath{
  ImageItem *item = [self.imageList objectAtIndex:indexPath.row];
  return item.calculatedCellHeight;
}

- (ImageItem *)itemAtIndexPath:(NSIndexPath *)indexPath{
  ImageItem *item = [self.imageList objectAtIndex:indexPath.row];
  return item;
}

- (void)scheduleImageDownloadForItemAtIndexPath:(NSIndexPath *) indexPath  canDownloadImageNow:(BOOL)yes{
  
  ImageItem *item = [self.imageList objectAtIndex:indexPath.row];
  //Early return is more readable than a huge compound condition
  //If the image is nil and its not downloading currently, make a download
  //operation for this image and enqueue it in main operation queue
  //A set of condition need to be evaluated before downloading an image
  //1, It should be empty but never tried downloading
  //2, A download is not already in progress
  //3, It sould have a non null url
  if (item.image) {
    return;
  }
  if (item.downloadInProgress) {
    return;
  }
  if (!item.imageURL) {
    return;
  }
  if (item.imageNotAvailable) {
    return;
  }
  if (yes) {
    DownloadImage *downlaodTask = [[DownloadImage alloc]initWithIndexPath:indexPath
                                                                 imageURL:item.imageURL
                                                              andDelegate:self];
    [self.operationQueue addOperation:downlaodTask];
    //set this flag to prevent multiple downloads
    item.downloadInProgress = YES;
    //Keep a dictionary of active downloads
    [self.downloadsInProgress setObject:downlaodTask forKey:indexPath];
  }
}

- (NSInteger)itemCount{
   return self.imageList.count;
}

- (void)cleanupMemory{
  for(ImageItem *item in self.imageList){
     [item cleanUp];
  }
}
#pragma mark operations
- (void)optimisedImageDownloadWithVisibleRows:(NSSet *)visibleRows {
  //Of the in progress downloads, cancell those downloads which are currently not visible.
  //Start download for new items, Set is helps with easy manipulation without loops and ensure uniqueness
  NSMutableSet *inprogressDownloads = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
  NSMutableSet *downloadsToCancell = [inprogressDownloads mutableCopy];
  NSMutableSet *newDownloads = [visibleRows mutableCopy];
  //remove the off screen downloads
  [newDownloads minusSet:inprogressDownloads];
  [downloadsToCancell minusSet:visibleRows];
  //Cancel NSOperation
  for (NSIndexPath *index in downloadsToCancell) {
    DownloadImage *downlaodTask = [self.downloadsInProgress objectForKey:index];
    [downlaodTask cancel];
    [self.downloadsInProgress removeObjectForKey:index];
  }
  //Spawn new operation
  for (NSIndexPath *index in newDownloads) {
    [self scheduleImageDownloadForItemAtIndexPath:index canDownloadImageNow:YES];
  }
}

- (void)suspendAllDownloads{
  self.operationQueue.suspended = YES;
}

- (void)resumeAllDownloads{
  self.operationQueue.suspended = NO;
}

- (void)cancellAllDownloads{
  [self.operationQueue cancelAllOperations];
}

#pragma mark DownloadImageDelegate

//There is a new image downloaded, update the UI
- (void)downloadComplete:(UIImage *)image AtIndexPath:(NSIndexPath *)indexPath isOperationCancelled:(BOOL)cancelled{
  ImageItem *item = [self.imageList objectAtIndex:indexPath.row];
  item.downloadInProgress = NO;
  //If the operation is cancelled, we need to retry getting the image , else mark as unavailable
  if (!cancelled&&!image) {
    item.imageNotAvailable = TRUE;
  }
  //Access the imageList object in main queue, this ensure
  //serial access and hence thread safety
  dispatch_async(dispatch_get_main_queue(), ^{
    item.image = image;
    if ([self.delegate respondsToSelector:@selector(updateRowAtIndexPath:)]) {
      [self.delegate updateRowAtIndexPath:indexPath];
      
    }
  });
}

@end
