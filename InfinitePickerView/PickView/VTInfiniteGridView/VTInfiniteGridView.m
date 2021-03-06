//
//  VTInfiniteGridView.m
//  VerticalInfiniteGridView
//
//  Created by Xummer on 12-11-14.
//  Copyright (c) 2012年 Xummer. All rights reserved.
//

#import "InfinitePickerGrid.h"
#import "InfinitePickerView.h"
#import "VTInfiniteGridView.h"
@interface VTInfiniteGridView()

@property (nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSMutableArray *visibleGrids;
@property (strong, nonatomic) NSMutableArray *gridReusableQueue;
@property (strong, nonatomic) UIView *containerView;

// setConttentOffset Animation
@property (nonatomic, getter = isOffsetAnimation) BOOL offsetAnimation;
@property (strong, nonatomic) void (^completion)(void);

- (void)tileGridsFromMinY:(CGFloat)minimumVisibleY toMaxY:(CGFloat)maximumVisibleY;

@end

@implementation VTInfiniteGridView

- (void)initialization {
    self.visibleGrids = [[NSMutableArray alloc] init];
    self.gridReusableQueue = [[NSMutableArray alloc] init];
    self.containerView = [[UIView alloc] init];
    self.circular = YES;
    self.paging = YES;
    self.currentIndex = 0;
    self.delegate = self;
    
    [self addSubview:self.containerView];
    
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib {
    CGSize gridSize = [self.dataSource infiniteGridSize];
    NSUInteger totalGrids = [self.dataSource numberOfInfiniteGrids];
    self.contentSize = CGSizeMake( gridSize.width, 5 * totalGrids * gridSize.height);
    
    self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    if (!self.dragging) {
        UITouch *touch = [touches anyObject];
        CGPoint newPoint = [touch locationInView:self];
        UIView *result = [self gridViewAtPoint:newPoint];
        if (self.gridDelegate && [self.gridDelegate respondsToSelector:@selector(infiniteGridView:didSelectGridAtIndex:)]) {
            [self.gridDelegate infiniteGridView:self didSelectGridAtIndex:result.tag];
        }
        if (self.gridDelegate && [self.gridDelegate respondsToSelector:@selector(infiniteGridView:didSelectGridCell:)]) {
            [self.gridDelegate infiniteGridView:self didSelectGridCell:result];
        }
        [self.nextResponder touchesEnded: touches withEvent:event];
    } else {
        [super touchesEnded: touches withEvent: event];
    }
}

- (void)jumpToIndex:(NSInteger)gridIndex {
    if (self.isCircular && gridIndex < 0) return;
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:NO];
    
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
    
    [self.visibleGrids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *visibleGridView = (UIView *)obj;
        [visibleGridView removeFromSuperview];
    }];
    
    [self.visibleGrids removeAllObjects];
    self.currentIndex = gridIndex;
    
    [self tileGridsFromMinY:minimumVisibleY toMaxY:maximumVisibleY];
    
}

- (id)dequeueReusableGrid {
    id grid = [self.gridReusableQueue lastObject];
    [self.gridReusableQueue removeObject:grid];
    return grid;
}

#pragma mark - Layout

// recenter content periodically
- (void)recenterIfNecessary {
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentHeight = self.contentSize.height;
    CGFloat centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);
    
    if (distanceFromCenter > (contentHeight / 4.0)) {
        self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
        
        for (UIView *grid in self.visibleGrids) {
            CGPoint center = [self.containerView convertPoint:grid.center toView:self];
            center.y += (centerOffsetY - currentOffset.y);
            grid.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    // tile content in visible bounds
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
    
    [self tileGridsFromMinY:minimumVisibleY toMaxY:maximumVisibleY];
}

#pragma mark - Grid Tiling

- (UIView *)insertGridWithIndex:(NSInteger)index {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(infiniteGridView:forIndex:)]) {
        UIView *viewFromDelegate = [self.dataSource infiniteGridView:self forIndex:index];
        viewFromDelegate.tag = index;
        [self.containerView addSubview:viewFromDelegate];
        
        return viewFromDelegate;
    }
    
    return nil;
}

- (CGFloat)placeNewGridOnBottom:(CGFloat)bottomEdge {
    if ([self.visibleGrids count] > 0) {
        UIView *lastGrid = [self.visibleGrids lastObject];
        NSInteger nextIndex = lastGrid.tag + 1;
        if ([self isCircular])
            nextIndex = (nextIndex >= [self.dataSource numberOfInfiniteGrids]) ? 0 : nextIndex;
        self.currentIndex = nextIndex;
    }
    
    UIView *grid = [self insertGridWithIndex:self.currentIndex];
    [self.visibleGrids addObject:grid];
    
    CGRect frame = grid.frame;
    frame.origin.x = self.containerView.bounds.size.width - frame.size.width; 
    frame.origin.y = bottomEdge;
    grid.frame = frame;
    
    return CGRectGetMaxY(frame);
}

- (CGFloat)placeNewLabelOnTop:(CGFloat)TopEdge {
    UIView *firstGrid = [self.visibleGrids objectAtIndex:0];
    NSInteger previousIndex = firstGrid.tag - 1;
    if ([self isCircular])
        previousIndex = (previousIndex < 0) ? [self.dataSource numberOfInfiniteGrids]-1 : previousIndex;
    self.currentIndex = previousIndex;
    
    UIView *grid = [self insertGridWithIndex:self.currentIndex];
    [self.visibleGrids insertObject:grid atIndex:0];
    
    CGRect frame = grid.frame;
    frame.origin.x = self.containerView.bounds.size.width - frame.size.width;
    frame.origin.y = TopEdge - frame.size.height;
    grid.frame = frame;
    
    return CGRectGetMinY(frame);
}

- (void)tileGridsFromMinY:(CGFloat)minimumVisibleY toMaxY:(CGFloat)maximumVisibleY {
    if ([self.visibleGrids count] == 0) {
        [self placeNewGridOnBottom:minimumVisibleY];
    }
    
    UIView *lastGrid = [self.visibleGrids lastObject];
    CGFloat bottomEdge = CGRectGetMaxY(lastGrid.frame);
    while (bottomEdge < maximumVisibleY) {
        bottomEdge = [self placeNewGridOnBottom:bottomEdge];
    }
    
    UIView *firstGrid = [self.visibleGrids objectAtIndex:0];
    CGFloat topEdge = CGRectGetMinY(firstGrid.frame);
    while (topEdge > minimumVisibleY) {
        topEdge = [self placeNewLabelOnTop:topEdge];
    }
    
    lastGrid = [self.visibleGrids lastObject];
    while (lastGrid.frame.origin.y > maximumVisibleY) {
        [lastGrid removeFromSuperview];
        [self.visibleGrids removeLastObject];
        [self.gridReusableQueue addObject:lastGrid];
        
        lastGrid = [self.visibleGrids lastObject];
    }
    
    firstGrid = [self.visibleGrids objectAtIndex:0];
    while (CGRectGetMaxY(firstGrid.frame) < minimumVisibleY) {
        [firstGrid removeFromSuperview];
        [self.visibleGrids removeObjectAtIndex:0];
        [self.gridReusableQueue addObject:firstGrid];
        
        firstGrid = [self.visibleGrids objectAtIndex:0];
    }
}

- (UIView *)gridViewAtPoint:(CGPoint)point {
    __block UIView *gridView = nil;
    [self.visibleGrids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *visibleGridView = (UIView *)obj;
        
        if (CGRectContainsPoint(visibleGridView.frame, point)) {
            gridView = visibleGridView;
            *stop = YES;
        }
    }];
    
    return gridView;
}

- (void)reloadDataAndJumpToIndex:(NSInteger)gridIndex
{
    [self.gridReusableQueue removeAllObjects];
    [self jumpToIndex:gridIndex];
}

- (void)reloadData
{
    [self reloadDataAndJumpToIndex:0];
}

#pragma mark just for picker
- (void)unselectAllGrid
{
    if ([self.gridDelegate isKindOfClass:[InfinitePickerView class]]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.gridDelegate selector:@selector(highlightSelectColor:) object:nil];
        [self.visibleGrids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[InfinitePickerGrid class]]) {
                InfinitePickerGrid *visibleGridView = (InfinitePickerGrid *)obj;
                if (visibleGridView.selected) {
                    visibleGridView.selected = NO;
                }
            }
        }];
    }
}

- (void)determineCurrentRow:(UIScrollView *)scrollView
{
    if ([self isPaging]) {
        
        UIView *grid = [self gridViewAtPoint:scrollView.contentOffset];
        CGPoint localPoint = [scrollView convertPoint:scrollView.contentOffset toView:grid];
        //        CGFloat dy = 0;
        CGPoint destinationPoint;
        if (localPoint.y > (grid.bounds.size.height / 2)) {
            destinationPoint = [grid convertPoint:CGPointMake(0.0, grid.bounds.size.height) toView:scrollView];
            //            NSLog(@">");
        } else {
            destinationPoint = [grid convertPoint:CGPointMake(0.0, 0.0) toView:scrollView];
            //            NSLog(@"<");
        }
        __unsafe_unretained VTInfiniteGridView *weakSelf = self;
        [self setAnimationContentOffset:destinationPoint
                             completion:^{
                                 if (weakSelf.gridDelegate) {
                                     // first visible grid index
                                     UIView * grid = [weakSelf gridViewAtPoint:destinationPoint];
                                     if ([weakSelf.gridDelegate respondsToSelector:@selector(pickerContentGridView:selectedGridCell:)]) {
                                         [weakSelf.gridDelegate pickerContentGridView:weakSelf selectedGridCell:grid];
                                     }
                                     if ([weakSelf.gridDelegate respondsToSelector:@selector(pickerContentGridView:selectedIndex:)]) {
                                         [weakSelf.gridDelegate pickerContentGridView:weakSelf selectedIndex:grid.tag];
                                     }
                                 }
                             }];
        
        
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    self.completion = nil;
    [super setContentOffset:contentOffset animated:animated];
}

- (void)setAnimationContentOffset:(CGPoint)contentOffset completion:(void (^)(void))completion
{
    self.completion = completion;
    [super setContentOffset:contentOffset animated:YES];
}

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_completion != nil) {
        _completion();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self unselectAllGrid];
}

// custom paging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self determineCurrentRow:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self determineCurrentRow:scrollView];
}

@end
