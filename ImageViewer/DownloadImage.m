//
//  DownloadImage.m
//  ImageViewer
//
//  Created by Tony Thomas on 07/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import "DownloadImage.h"

@interface DownloadImage(){
    
    
}
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSURLSessionDataTask *imageDataTask;
@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) NSString *imageURL;
@end

@implementation DownloadImage

-(id)initWithIndexPath:(NSIndexPath *)path imageURL:(NSString *)url andDelegate:(id)downloadImageDelegate{
  self = [super init];
  self.indexPath = path;
  self.delegate = downloadImageDelegate;
  self.imageURL = url;
  return self;
}
//Main method override from NSOperation
- (void)main {
  __weak __typeof__(self) weakSelf = self;
  NSURL *url = [NSURL URLWithString:self.imageURL];
  self.imageDataTask = [[NSURLSession sharedSession]
                        dataTaskWithURL:url
                        completionHandler:^(NSData * _Nullable
                                            data, NSURLResponse * _Nullable
                                            response, NSError * _Nullable error) {
                          
                          __typeof__(self) strongSelf = weakSelf;
                          if (error) {
                            //upgate the image download progress if it failed or the task is
                            //cancelled this will reset the download progress flag
                            if ([strongSelf.delegate respondsToSelector:@selector(downloadComplete: AtIndexPath: isOperationCancelled:)]) {
                              [strongSelf.delegate downloadComplete:nil AtIndexPath:strongSelf.indexPath isOperationCancelled:NO];
                            }
                            return;
                          }
                          //Update the new image and it will trigger a UI update in the tableview
                          //row
                          UIImage *image = [UIImage imageWithData:data];
                          if ([strongSelf.delegate respondsToSelector:@selector(downloadComplete: AtIndexPath: isOperationCancelled:)]) {
                          [strongSelf.delegate downloadComplete:image AtIndexPath:strongSelf.indexPath isOperationCancelled:NO];
                          }
                          //We may resize the image to have more fluid experience,now assuming
                          //all images are small
                        }];
  if (self.isCancelled) {//check weather the task is cancelled.
    if ([self.delegate respondsToSelector:@selector(downloadComplete: AtIndexPath: isOperationCancelled:)]) {
      [self.delegate downloadComplete:nil AtIndexPath:self.indexPath isOperationCancelled:NO];
    }
  }
  [self.imageDataTask resume];
}
- (void)cancel{
  //We may need to cancel the download for an invisible row if we have a large number of
  //rows, in those case the priority is to download the images for the visible rows first
  //This will speed up the loading in visible rows and the user get a responsive UI
  [self.imageDataTask cancel];
  if ([self.delegate respondsToSelector:@selector(downloadComplete: AtIndexPath: isOperationCancelled:)]) {
    [self.delegate downloadComplete:nil AtIndexPath:self.indexPath isOperationCancelled:NO];
  }
}
@end