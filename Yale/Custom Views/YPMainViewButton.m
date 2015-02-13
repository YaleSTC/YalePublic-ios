//
//  YPMainViewButton.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPMainViewButton.h"
#import <PureLayout/PureLayout.h>

#define FONT [UIFont systemFontOfSize:10]

@interface YPMainViewButton() {
  BOOL _hasSetupConstraint;
}

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation YPMainViewButton

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder]) {
    [self _commonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self _commonInit];
  }
  return self;
}

- (instancetype)initForAutoLayout
{
  if (self = [super initForAutoLayout]) {
    [self _commonInit];
  }
  return self;
}

- (void)_commonInit
{
  self.iconView       = [UIImageView newAutoLayoutView];
  self.underTextLabel = [UILabel newAutoLayoutView];
  
  [self addSubview:self.iconView];
  [self addSubview:self.underTextLabel];
}

#pragma mark - Setters

- (void)setIcon:(UIImage *)icon
{  
  if (_icon != icon) {
    _icon = icon;
    self.iconView.image = icon;
  }
  
  [self setNeedsUpdateConstraints];
}

- (void)setUnderText:(NSString *)underText
{
  _underText = underText;
  
  self.underTextLabel.text      = underText;
  self.underTextLabel.font      = FONT;
  self.underTextLabel.textColor = [UIColor whiteColor];
  self.underTextLabel.textAlignment = NSTextAlignmentCenter;
  
  [self.underTextLabel removeConstraints:self.underTextLabel.constraints];
  
  [self _resizeUnderTextLabel];
  
  [self setNeedsUpdateConstraints];
}

#pragma mark - Constraints and sizes

+ (BOOL)requiresConstraintBasedLayout
{
  return YES;
}

- (void)_resizeUnderTextLabel
{
  CGSize size = [self textLabelSize];
  size.height = ceil(size.height);
  size.width  = ceil(size.width);
  [self.underTextLabel autoSetDimensionsToSize:size];
  [self.underTextLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
}


- (CGSize)textLabelSize
{
  //not necessary to base this on the actual text, since now the text is centered.
  return CGSizeMake(self.bounds.size.width, UNDER_TEXT_HEIGHT);
}

- (void)updateConstraints
{
  if (!_hasSetupConstraint) {
    [self.iconView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero
                                            excludingEdge:ALEdgeBottom];
    [self.iconView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.iconView];
    
    [self.underTextLabel autoPinEdge:ALEdgeTop
                              toEdge:ALEdgeBottom
                              ofView:self.iconView
                          withOffset:IMAGE_TEXT_MARGIN];
    
    
    [self _resizeUnderTextLabel];
    
    _hasSetupConstraint = YES;
  }
  
  [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
  CGFloat width = self.icon.size.width;
  NSLog(@"%f", width);
  return CGSizeMake(width, width + IMAGE_TEXT_MARGIN + [self textLabelSize].height);
}

#pragma mark - View update

- (void)setHighlighted:(BOOL)highlighted
{
  [super setHighlighted:highlighted];
  self.alpha = (highlighted) ? 0.5 : 1;
}

#pragma mark - View properties

- (BOOL)isOpaque
{
  return NO;
}

@end
