//
//  ViewController.m
//  InfinitePickerView
//
//  Created by Xummer on 13-3-21.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *dataArray = @[@"0", @"1", @"2", @"3", @"4", @"5"];
    InfinitePickerView *pickerView = [[InfinitePickerView alloc] initWithData:dataArray maskIndex:1 startIndex:0];
    [pickerView setPickerDelegate:self];
    
    CGRect frame = pickerView.frame;
    frame.origin = CGPointMake(10, 40);
    [pickerView setFrame:frame];
    [self.view addSubview:pickerView];
    [pickerView release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ICPickerView delegate
- (void)pickerView:(InfinitePickerView *)picker didSelectAtIndex:(NSInteger)selectIndex
{
    NSLog(@"select index %d  <%@>", selectIndex, picker);
}

@end
