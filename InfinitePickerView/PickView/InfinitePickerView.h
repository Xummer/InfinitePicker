//
//  VTInfinitePickView.h
//  constomPickerView
//
//  Created by Xummer on 13-1-15.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTInfiniteGridView.h"
@class InfinitePickerView;
@protocol InfiPickerDelegate <NSObject>
@optional
- (void)pickerView:(InfinitePickerView *)picker didSelectAtIndex:(NSInteger)selectIndex;

@end

@interface InfinitePickerView : UIView <VTInfiniteGridDataSource, VTInfiniteGridDelegate>
@property (retain, nonatomic) IBOutlet VTInfiniteGridView *pickContentView;
@property (retain, nonatomic) IBOutlet UIImageView *pickMaskView;
@property (nonatomic, assign) id<InfiPickerDelegate> pickerDelegate;
@property (nonatomic, assign) NSInteger pickerMaskIndex;    // start from 0
@property (nonatomic, assign) NSInteger pickerResult;
@property (nonatomic, assign) NSInteger visibleGridCount;   // defualt is 7

@property (nonatomic, retain) NSArray *dataArray;

- (id)initWithData:(NSArray *)pDataArr maskIndex:(NSInteger)mIndex startIndex:(NSInteger)sIndex;
- (void)reloadData;
- (void)reloadDataWithMaskIndex:(NSInteger)mIndex startIndex:(NSInteger)sIndex;

@end
