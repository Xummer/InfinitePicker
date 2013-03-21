# InfinitePicker #

Xummer

![](http://tp4.sinaimg.cn/1994914167/180/5650638007/1)  
**[Follow Me On Weibo](http://weibo.com/xummers)**

## Over View
用了[ixnixnixn](https://github.com/ixnixnixn)的[IAInfiniteGridView](https://github.com/ixnixnixn/IAInfiniteGridView)改了个竖版的循环VTInfiniteGridView。  
再在外面套了一个View作为picker的响应。  
![](http://farm9.staticflickr.com/8391/8575948507_a3581769d1.jpg)

## How To
1.用的是nonarc，所以需要在VTInfiniteGridView加arc编译标记 -fobjc-arc  
![](http://farm9.staticflickr.com/8249/8575947719_de234dd72f.jpg)  
  Ps：如果需要导入arc的工程，在InfinitePickerGrid.m和InfinitePickerView.m中加编译标记 -fno-objc-arc


2.设置delegate

	@interface ViewController : UIViewController <InfiPickerDelegate>	
3.具体使用（maskIndex:从0开始 starIndex:从0开始）

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

