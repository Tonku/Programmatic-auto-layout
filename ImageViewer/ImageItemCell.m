//
//  ImageItemCell.m
//  ImageViewer
//
//  Created by Tony Thomas on 08/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//


#import "ImageItemCell.h"
#import "Constants.h"
#import "ImageItem.h"
@interface ImageItemCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *photoView;

@end

@implementation ImageItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    //Title
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    //Image
    self.photoView = [[UIImageView alloc]init];
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.photoView];
    //Description
    self.descriptionLabel = [[UILabel alloc]init];
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //Keep the font size to what we have used to measure the text content size
    self.descriptionLabel.font = [UIFont systemFontOfSize:kFontSize];
    //Make it multi line
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.descriptionLabel];
    [self setAutoLayout];
  }
  return self;
}

//Set auto layout for the content view
- (void)setAutoLayout{
  self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.photoView.translatesAutoresizingMaskIntoConstraints = NO;
  self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  NSDictionary *elementsDict = NSDictionaryOfVariableBindings(_titleLabel, _photoView, _descriptionLabel);
  NSDictionary *metrics = @{
                            @"titleHeight" : @kTitleHeight,
                            @"imageHeight" : @kImageHeight,
                            
                            };
  //Set the constraints in VFL , stack vertically
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_titleLabel(titleHeight)]-0-[_photoView(imageHeight)]-0-[_descriptionLabel]-0-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:metrics
                                                                             views:elementsDict]];
  //Horizontal
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_titleLabel]-0-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:nil
                                                                             views:elementsDict]];
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_photoView]-0-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:nil
                                                                             views:elementsDict]];
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_descriptionLabel]-0-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:nil
                                                                             views:elementsDict]];
}
//Set the content
- (void)setContent:(ImageItem *)item{
  self.descriptionLabel.text = item.imageDescription;
  //Set a dummy image for place holder
  if (item.image) {
    self.photoView.image = item.image;
  }
  else{
    self.photoView.image = [UIImage imageNamed:@"placeholderImage"];
  }
  self.titleLabel.text = item.title;
}
@end
