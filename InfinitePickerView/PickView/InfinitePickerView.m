//
//  VTInfinitePickView.m
//  constomPickerView
//
//  Created by Xummer on 13-1-15.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#define PICKER_GRIDVIEW_HEIGHT  50.0f
#define PICKER_GRIDVIEW_WIDTH   300.0f
#define DEFUALT_VISIBLE_GRID_COUNT  7

#define kPickMaskImage  @"pick_masker_bg.png"

#define kBGColor        [UIColor blackColor]

#import "InfinitePickerView.h"
#import "InfinitePickerGrid.h"

@interface InfinitePickerView ()

@end

@implementation InfinitePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    // initialization with defualt paramete
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < DEFUALT_VISIBLE_GRID_COUNT; i ++) {
        [tempArray addObject:@""];
    }
    self.dataArray =tempArray;
    [tempArray release];
    _visibleGridCount = DEFUALT_VISIBLE_GRID_COUNT;
    _pickerMaskIndex = 0;
    _pickerResult = 0;
}

- (id)initWithData:(NSArray *)pDataArr maskIndex:(NSInteger)mIndex startIndex:(NSInteger)sIndex
{
    NSArray *subviews = [[NSBundle mainBundle] loadNibNamed:@"InfinitePickerView" owner:self options:nil];
    InfinitePickerView *instanceView = [subviews objectAtIndex:0];
    self = [instanceView retain];
    
    _pickerMaskIndex = mIndex;
    
    self.dataArray = pDataArr;
    [self reloadDataWithMaskIndex:mIndex startIndex:sIndex];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:kBGColor];
    
    // pickMaskView
    NSAssert(self.pickMaskView != nil, @"layoutSubViews pcikMaskView is nil");
    if (self.pickMaskView) {
        CGRect frame = self.pickMaskView.frame;
        frame.origin.y = _pickerMaskIndex * PICKER_GRIDVIEW_HEIGHT;
        [self.pickMaskView setFrame:frame];
        
        UIImage *maskBG = [UIImage imageNamed:kPickMaskImage];
        [self.pickMaskView setImage:[maskBG stretchableImageWithLeftCapWidth:0 topCapHeight:15]];
    }
}

- (void)dealloc {
    
    [_pickContentView release];
    [_dataArray release];
    
    [_pickMaskView release];
    [super dealloc];
}

- (void)setPickerMaskIndex:(NSInteger)pickerMaskIndex
{
    _pickerMaskIndex = pickerMaskIndex%_visibleGridCount;
    [self setNeedsLayout];
}

- (void)reloadData
{
    [self reloadDataWithMaskIndex:_pickerMaskIndex startIndex:0];
}

- (void)reloadDataWithMaskIndex:(NSInteger)mIndex startIndex:(NSInteger)sIndex
{
    self.pickerMaskIndex = mIndex;
    [self.pickContentView reloadDataAndJumpToIndex:([self numberOfInfiniteGrids] - _pickerMaskIndex+sIndex)%[self numberOfInfiniteGrids]];
}

- (void)highlightSelectColor
{
    CGPoint maskPoint = [self convertPoint: CGPointMake(0.0f, _pickerMaskIndex * PICKER_GRIDVIEW_HEIGHT) toView:_pickContentView];
    InfinitePickerGrid *selectGrid = (InfinitePickerGrid *)[_pickContentView gridViewAtPoint:maskPoint];
    [selectGrid setSelected:YES];
}

- (void)selectRowAfterAnimation
{
    [self highlightSelectColor];
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(pickerView:didSelectAtIndex:)]) {
        [_pickerDelegate pickerView:self didSelectAtIndex:_pickerResult];
    }
}

#pragma mark - VTInfiniteGridView Data Source Methods
- (UIView *)infiniteGridView:(VTInfiniteGridView *)gridView forIndex:(NSInteger)gridIndex {
    InfinitePickerGrid *grid = [self.pickContentView dequeueReusableGrid];
    if (grid == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, [self infiniteGridSize].width, [self infiniteGridSize].height);
        grid = [[[InfinitePickerGrid alloc] initWithFrame:frame] autorelease];
    }
    
    NSInteger gridNum = [self numberOfInfiniteGrids];
    if (gridNum > 0) {
        if (gridIndex%gridNum == 0) {
            [grid.lineImageView setHidden:NO];
        }else{
            [grid.lineImageView setHidden:YES];
        }
        [grid.textLabel setText:_dataArray[gridIndex%gridNum]];
    }
    
    return grid;
}

- (NSUInteger)numberOfInfiniteGrids {
    return [_dataArray count];
}

- (CGSize)infiniteGridSize {
    
    return CGSizeMake(PICKER_GRIDVIEW_WIDTH, PICKER_GRIDVIEW_HEIGHT);
}

#pragma mark grid delegate

- (void)infiniteGridView:(VTInfiniteGridView *)gridView didSelectGridCell:(UIView *)gridCell
{
    self.pickerResult = gridCell.tag;
    
    CGPoint currentPoint = [_pickContentView convertPoint:_pickContentView.contentOffset toView:gridCell];
    
    // visibleGirdIndex is the index of grid in visible grids
    NSInteger visibleGirdIndex = -currentPoint.y / PICKER_GRIDVIEW_HEIGHT;
    CGPoint destinationPoint = [gridCell convertPoint: CGPointMake(0.0f, currentPoint.y - (_pickerMaskIndex - visibleGirdIndex) * PICKER_GRIDVIEW_HEIGHT) toView:_pickContentView];
    
    // if select the maskeIndex cell there is no content offset animation
    if (_pickerMaskIndex - visibleGirdIndex == 0) {
        [self selectRowAfterAnimation];
    }else{
        // animation duration is about 0.3+ABS((_pickerMaskIndex - visibleGirdIndex))*0.1
        [_pickContentView setUserInteractionEnabled:NO];
        [_pickContentView setAnimationContentOffset:destinationPoint
                                         completion:^{
                                             [self selectRowAfterAnimation];
                                             [_pickContentView setUserInteractionEnabled:YES];
                                         }];
    }
}

#pragma mark - VTInfiniteGridView Delegate
- (void)pickerContentGridView:(VTInfiniteGridView *)gridView selectedIndex:(NSInteger)selectIndex
{
    /*
     *  picker index start from 0
     *  
     * - - - - - - - 
     *  0
     *  1
     *  ...
     * --------------   visiable picker
     *  Start Index     <= gridCell Index
     *  ...             visiableNumberOfGrids: visiable number of grids 
     * [             ]  <= pickerMaskIndex: picker MaskView index
     *  End Index       
     * --------------
     *  ...
     *  last 
     * - - - - - - -
     */
    NSInteger endIndex = selectIndex;
    endIndex += _pickerMaskIndex;
    while (endIndex < 0) {
        endIndex += _visibleGridCount;
    }
    NSInteger gridsCount = [self numberOfInfiniteGrids];
    if (endIndex > gridsCount-1) {
        endIndex %= gridsCount;
    }
    
    self.pickerResult = endIndex;
    
    [self highlightSelectColor];
    
}

@end
