# HHHorizontalPagingView
对HHHorizontalPagingView的优化，解决headerView 的点击痛点

![演示](http://i.niupic.com/images/2016/09/27/B7QqwZ.gif)

#CocoaPods

通过CocoaPods集成

	pod 'JYHHHorizontalPagingView'        

我的这个是针对[Huanhoo/HHHorizontalPagingView](https://github.com/Huanhoo/HHHorizontalPagingView)的修改，HHHorizontalPagingView是一个实现上下滚动时菜单悬停在顶
端，并且可以左右滑动切换的视图，实现思路非常巧妙：
	
	HHHorizontalPagingView 通过重写 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event方法 将headerView 上的响应作用在了 self.currentScrollView (当前展现的scrollerView)上，滚动就根据contentOffset来移动headerView。点击就调用 @property (nonatomic, copy) void (^clickEventViewsBlock)(UIView *eventView); eventView 是hitTest方法查找到的view。
	
	缺点：1.只要headerView稍微复杂点，点击事件就非常难以处理。
	     2.左右滑动的View过多时，在内存中均无法释放。
	
	而我的修改就是为了解决这两个问题，事件点击是最关键的。
	

一、点击事件的处理
	
点击难以处理主要是，作者为了实现该效果，重写hitTest方法，导致了headerView响应者链条的断裂，
虽然作者提供了一个block回调，但对于点击处理无疑是反人类。我的想法是在点击处理时将响应者链条接
起来。


1.[响应者链条](http://www.jianshu.com/p/2c5678c659d5)可以看看该文章 以下是摘抄：

	iOS使用“命中测试”（hit-testing）去寻找触摸发生下的view。命中测试会执行检测判断
	是否改触摸点发生在某个具体的view的相对边界之内。如果检测是的，它就会递归的去检测该view的
	所有子view。该view的层级最底端view包含触摸点，它就成为了“命中测试view”。之后iOS就会决
	定谁是命中测试view,并且递交触摸事件给它处理。
	
	命中测试view 被赋予了第一个处理触摸事件的机会，如果命中测试view不能处理该事件，该事件就
	会交付给view响应者链的上一级处理直到系统找到一个能够处理该事件的对象。
	
2.接起响应者链条
	
	Huanhoo 使用@property (nonatomic, copy) void (^clickEventViewsBlock)
	(UIView *eventView);来处理点击事件，而eventView就是 命中测试view ， 而我要做的
	就是通过这个命中测试view向上查找处理该事件。

	实现方法：
	引入UIView+WhenTappedBlocks这是一个手势处理的分类，
	#pragma mark - 模拟响应者链条 由被触发的View 向它的兄弟控件 父控件 延伸查找响应
		- (void)viewWasTappedPoint:(CGPoint)point{
		    [self clickOnThePoint:point];
		}
		
		- (BOOL)clickOnThePoint:(CGPoint)point{
		    
		    if ([self.superview isKindOfClass:[UIWindow class]]) {
		        return NO;
		    }
		    
		    if (self.block) {
		        self.block();
		        return YES;
		    }
		    
		    __block BOOL click = NO;
		    // 看兄弟控件
		    [self.superview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		        // 转换坐标系 看点是否在View上
		        CGPoint objPoint = [obj convertPoint:point fromView:self];
		        if (!CGRectContainsPoint(obj.frame, objPoint)) {
		            //            NSLog(@"-----%@",NSStringFromCGPoint(objPoint));
		            return;
		        }
		        if (self.block) {
		            self.block();
		            click = YES;
		            *stop = YES;
		        }
		    }];
		    
		    if (!click) {
		        return [self.superview clickOnThePoint:point];
		    }
		    
		    return click;
		}
		
	正常响应，有点击手势触发方法来执行block，非正常点击 主动调用
	- (void)viewWasTappedPoint:(CGPoint)point;方法就可以接起响应者链条。
	
	
二、左右滑动的View过多时的内存问题
	
	
	/／ 缓存视图数 默认是 3
	@property (nonatomic, assign) CGFloat maxCacheCout;
	该属性是最大的View引用数，超过的会释放回收。
	
	一个界面的展现，分为数据和视图，其中大部分内存为视图所占用，我们只需要保存界面数据，和离开
	界面时的位置，下次创建时还原即可，不过视图的创建和释放都是比较耗性能的，会卡顿主线程。
	
	
	

	
	
	
	