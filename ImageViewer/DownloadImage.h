//
//  DownloadImage.h
//  ImageViewer
//
//  Created by Tony Thomas on 07/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

//This protocol when implemented gets notification, when the download is
//complete
@protocol DownloadImageDelegate<NSObject>

//The download complete alert for an image at specified index path
- (void)downloadComplete:(UIImage *)image AtIndexPath:(NSIndexPath *)indexPath isOperationCancelled:(BOOL)cancelled;

@end

//This NSOperation sub class downloads the image from the url, which is assosciated with
//it.It uses NSURLSession to download the image.
@interface DownloadImage : NSOperation

//the designated initialiser, |path| is the index path of the object |url| the image url and
//|downloadImageDelegate| is the DownloadImageDelegate
-(id)initWithIndexPath:(NSIndexPath *)path imageURL:(NSString *)url andDelegate:(id)downloadImageDelegate;

@end