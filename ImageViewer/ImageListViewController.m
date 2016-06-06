//
//  ImageListViewController.m
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#include "Constants.h"
#import "ImageListViewController.h"
#import "ImageItem.h"
#import "ImageViewModel.h"
#import "ImageItemCell.h"

@interface ImageListViewController()<ImageViewModelDelegate>

@property (nonatomic, strong) ImageViewModel *viewModel;
@end

@implementation ImageListViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.viewModel = [[ImageViewModel alloc]initWithDelegate:self];
  self.refreshControl = [[UIRefreshControl alloc]init];
  [self.tableView addSubview:self.refreshControl];
  [self.refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  //Cancell all operations to save memory
  [self.viewModel cancellAllDownloads];
}

-(void)viewDidUnload{
  //Cancell all operations to save memory
  [self.viewModel cancellAllDownloads];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.viewModel.itemCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.viewModel heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"ImageViewCell";
  ImageItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[ImageItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  //For highly optimed result #define HIGH_OPTIMISATION, but the code perfoms well even witout high optimisation
  //This optimisation is disabled now , to enable please see constants.h
#ifdef HIGH_OPTIMISATION
  BOOL shouldScheduleImageDownload = !tableView.dragging && !tableView.decelerating;
  if (shouldScheduleImageDownload) {
    [self.viewModel optimisedImageDownloadWithVisibleRows: [NSSet setWithArray:tableView.indexPathsForVisibleRows]];
  }
#else
  [self.viewModel optimisedImageDownloadWithVisibleRows: [NSSet setWithArray:tableView.indexPathsForVisibleRows]];
#endif
  ImageItem *imgItem = [self.viewModel itemAtIndexPath:indexPath];
  [cell setContent:imgItem];
  return cell;
}

#pragma mark - ImageViewModelDelegate
//Informs that there is an update for the model, along with its title
- (void)modelUpdatedWithTitle:(NSString *)title{
  //Always do the UI tasks in main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    self.title = title;
    [self.tableView reloadData];
  });
}

- (void)updateRowAtIndexPath:(NSIndexPath *)indexPath{
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath ] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark - UIScrollView delegate
//This optimisation is disabled now , to enable please see constants.h
#ifdef HIGH_OPTIMISATION
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
  [self.viewModel suspendAllDownloads];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
  if (!decelerate) {
    [self.viewModel optimisedImageDownloadWithVisibleRows: [NSSet setWithArray:self.tableView.indexPathsForVisibleRows]];
    [self.viewModel resumeAllDownloads];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
  [self.viewModel optimisedImageDownloadWithVisibleRows: [NSSet setWithArray:self.tableView.indexPathsForVisibleRows]];
  [self.viewModel resumeAllDownloads];
}
#endif
#pragma mark - private methods
- (void)refreshTableView{
  [self.refreshControl endRefreshing];
  self.viewModel = [[ImageViewModel alloc]initWithDelegate:self];
}
@end
