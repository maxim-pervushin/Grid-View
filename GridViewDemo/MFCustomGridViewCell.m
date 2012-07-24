//
//  MFCustomGridViewCell.m
//  GridViewDemo
//
//  Created by Maxim Pervushin on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MFCustomGridViewCell.h"

@interface MFCustomGridViewCell ()
{
    UIView *_contentView;
}

@end

@implementation MFCustomGridViewCell

- (void)dealloc
{
    [_contentView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
//        CGRect contentViewFrame = CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
//        _contentView = [[UIView alloc] initWithFrame:contentViewFrame];
        _contentView = [[UIView alloc] init];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.backgroundColor = [UIColor colorWithWhite:(CGFloat)(arc4random() % 254) / 254 alpha:1];
        [self addSubview:_contentView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
}

@end
