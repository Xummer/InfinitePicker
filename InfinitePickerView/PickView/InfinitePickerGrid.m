//
//  VTInfinitePickGrid.m
//  constomPickerView
//
//  Created by Xummer on 13-1-15.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#define kLineImage      @"dottedline_pic.png"

#import "InfinitePickerGrid.h"

@implementation InfinitePickerGrid

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialGrid];
    }
    return self;
}

- (void)initialGrid
{
    CGRect frame = self.frame;
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame];
    [tempLabel setTextAlignment:NSTextAlignmentCenter];
    [tempLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:tempLabel];
    self.textLabel = tempLabel;
    [tempLabel release];
    [self setSelected:NO];
    
    frame.origin.x += 13.0f;
    frame.size.width -= 2*13.0f;
    frame.size.height = 2.0f;
    UIImageView *tempLineImageView = [[UIImageView alloc] initWithFrame:frame];
    [tempLineImageView setImage:[UIImage imageNamed:kLineImage]];
    [tempLineImageView setHidden:YES];
    [self addSubview:tempLineImageView];
    self.lineImageView = tempLineImageView;
    [tempLineImageView release];
    
    [self updateFont];
}

- (void)updateFont
{
    [_textLabel setFont:[UIFont systemFontOfSize:14.0f]];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        [self.textLabel setTextColor:[UIColor whiteColor]];
    }else{
        [self.textLabel setTextColor:[UIColor colorWithRed:225.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1]];
    }
}

- (void)dealloc
{
    [_textLabel release];
    [_lineImageView release];
    
    [super dealloc];
}

@end
