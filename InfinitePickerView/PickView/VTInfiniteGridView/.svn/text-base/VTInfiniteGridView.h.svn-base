//
//  VTInfiniteGridView.h
//  VerticalInfiniteGridView
//
//  Created by Xummer on 12-11-14.
//  Copyright (c) 2012年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTInfiniteGridView;

@protocol VTInfiniteGridDataSource <NSObject>

@required
- (UIView *)infiniteGridView:(VTInfiniteGridView *)gridView forIndex:(NSInteger)gridIndex;
- (NSUInteger)numberOfInfiniteGrids;
- (CGSize)infiniteGridSize;

@end

@protocol VTInfiniteGridDelegate <NSObject>

@optional
- (void)infiniteGridView:(VTInfiniteGridView *)gridView didSelectGridAtIndex:(NSInteger)gridIndex;
- (void)infiniteGridView:(VTInfiniteGridView *)gridView didSelectGridCell:(UIView *)gridCell;
// pciker
- (void)pickerContentGridView:(VTInfiniteGridView *)gridView selectedIndex:(NSInteger)selectIndex;
- (void)pickerContentGridView:(VTInfiniteGridView *)gridView selectedGridCell:(UIView *)gridCell;

@end

@interface VTInfiniteGridView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, getter = isCircular) BOOL circular;
@property (nonatomic, getter = isPaging) BOOL paging;
@property (nonatomic, assign) IBOutlet id<VTInfiniteGridDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<VTInfiniteGridDelegate> gridDelegate;

- (id)dequeueReusableGrid;
- (void)jumpToIndex:(NSInteger)gridIndex;
- (UIView *)gridViewAtPoint:(CGPoint)point;
- (void)reloadDataAndJumpToIndex:(NSInteger)gridIndex;
- (void)reloadData;
- (void)setAnimationContentOffset:(CGPoint)contentOffset completion:(void (^)(void))completion;

@end
