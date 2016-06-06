//
//  ViewController.m
//  ImageViewer
//
//  Created by Tony Thomas on 06/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

#import "ViewController.h"
#import "ImageListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  //Create button
  UIButton *loadImages = [UIButton buttonWithType:UIButtonTypeSystem];
  [loadImages setTitle:@"Load images" forState:UIControlStateNormal];
  loadImages.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 40);
  loadImages.center = self.view.center;
  [self.view addSubview:loadImages];
  //set action
  [loadImages addTarget:self action:@selector(loadImages) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadImages{
  //Image viewer
  ImageListViewController *viewController = [[ImageListViewController alloc]init];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
