//
//  YPCircleView.m
//  Yale
//
//  Created by Lee Danilek on 2/16/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPCircleView.h"

@implementation YPCircleView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/5 startAngle:0 endAngle:2*M_PI clockwise:YES];
  [self.color setFill];
  [circlePath fill];
}


@end
