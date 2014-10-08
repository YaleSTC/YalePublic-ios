//
//  YPMainViewButtonCollectionViewCell.m
//  Yale
//
//  Created by Hengchu Zhang on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPMainViewButtonCollectionViewCell.h"
#import <PureLayout/PureLayout.h>

@interface YPMainViewButtonCollectionViewCell() {
  BOOL _hasUpdatedConstraints;
}

@end

@implementation YPMainViewButtonCollectionViewCell

- (instancetype)init
{
  if (self = [super init]) {
    [self _commonInit];
  }
  return self;
}

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

- (void)_commonInit
{
  self.button = [YPMainViewButton newAutoLayoutView];
  [self.contentView addSubview:self.button];
}

- (void)updateConstraints
{
  if (!_hasUpdatedConstraints) {
#warning TODO(Charly) The height is not constrained. This would create warning at runtime.
    [self.button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    _hasUpdatedConstraints = YES;
  }
  [super updateConstraints];
}

@end
