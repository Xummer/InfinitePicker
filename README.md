# InfinitePicker #

Xummer

![](http://tp4.sinaimg.cn/1994914167/180/5650638007/1)  
**[Follow Me On Weibo](http://weibo.com/xummers)**

## Over View
用了ixnixnixn的[IAInfiniteGridView](https://github.com/ixnixnixn/IAInfiniteGridView)改了个竖版的循环VTInfiniteGridView。再在外面套了一个View作为pick的响应。

## How To
1.需要在VTInfiniteGridView加arc编译标记 -fobjc-arc
2.设置delegate
	@interface ViewController : UIViewController <InfiPickerDelegate>	
3.具体使用
	NSArray *dataArray = @[@"0", @"1", @"2", @"3", @"4", @"5"];
	InfinitePickerView *pickerView = [[InfinitePickerView alloc] initWithData:dataArray maskIndex:1 startIndex:0];
	[pickerView setPickerDelegate:self];
	
	// 重设frame的origin
	CGRect frame = pickerView.frame;
	frame.origin = CGPointMake(10, 40);
	[pickerView setFrame:frame];
	[self.view addSubview:pickerView];
	[pickerView release];
4.实现protocol方法
	- (void)pickerView:(InfinitePickerView *)picker didSelectAtIndex:(NSInteger)selectIndex
	{
	    NSLog(@"select index %d  <%@>", selectIndex, picker);
	}

## All the notes are [MIT](http://www.opensource.org/licenses/mit-license.php) Licensed.

