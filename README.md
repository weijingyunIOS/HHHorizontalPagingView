# HHHorizontalPagingView


![演示](http://images2015.cnblogs.com/blog/737816/201612/737816-20161206111835101-2099066825.gif)


# 更新记录
### 1.2.0
	1.本版本适配了 iOS11。
	2.将SegmentView抽离支持用户自定义，自定义view只需支持JYSegmentViewProtocol协议即可。具体可参考默认的JYSegmentView

### 1.1.1 
	最新版采用手势模拟scrollView弹簧及减速效果，解决了之前篡改响应链的痛点
	完美兼容之前版本，设置 isGesturesSimulate 属性为YES就可以使用，模拟效果
	接近系统效果，事件响应也不会有问题，只在headerView加了拖拽手势，大家可以
	实现headerView上加轮播图的效果。

[可以看看简书介绍](http://www.jianshu.com/p/6897113b3e9f)
# 注意：
	类似功能的开源框架有不少，大家在要使用时请谨慎选择。
		1.为了达到 headerView 与 下方ScrollView 的流畅效果，窜改了headerView的响应者链
	条，虽然我用一种巧妙的方式接起了点击事件，但是除了点击事件，其它手势无法响应。也就是说 想
	在 headerView上做轮播图是无法做到的。
		2.Demo提供单独下拉，该方式需要对 刷新框架做一些处理，后面会讲到。
		3.关于整体下拉刷新，由于悬停效果处理会有很多坑，整体刷新采用微信朋友圈的刷新样式。
	刷新。通过下面的代理方法处理效果即可。
	- (void)pagingView:(HHHorizontalPagingView*)pagingView scrollTopOffset:(CGFloat)offset;
	
向大家推荐另外一个框架 :[YX_UITableView_IN_UITableView]( https://github.com/yixiangboy/YX_UITableView_IN_UITableView)
	
	该框架的实现方式大家可以看作者介绍，
	1.它的 headerView 可以正常响应所有事件，想在 headerView上做轮播图是没有问题的。
	2.做整体下拉刷新也是没有问题的，而且添加比较方便。
	问题：1.headerView 向上滑动 会在临界点停住，不会有本框架宛如一体的减速滚动效果。
		 2.本框架 Demo 中的 单独下拉刷新，作者没有处理，大家需要自己看代码进行改造（可能坑比
		 较多）。	
	
	
    
# CocoaPods

通过CocoaPods集成

	pod 'JYHHHorizontalPagingView', '~> 1.2.0'   
	如果搜索不到，请 pod repo update 更新仓库     


# 实现原理以及介绍
我的这个是针对[Huanhoo/HHHorizontalPagingView](https://github.com/Huanhoo/HHHorizontalPagingView)的修改，HHHorizontalPagingView是一个实现上
下滚动时菜单悬停在顶端，并且可以左右滑动切换的视图，实现思路非常巧妙：
	
	HHHorizontalPagingView 通过重写 - (UIView *)hitTest:(CGPoint)point 
	withEvent:(UIEvent *)event方法 将headerView 上的响应作用在了 
	self.currentScrollView (当前展现的scrollerView)上，滚动就根据contentOffset来移动
	headerView。点击就调用 @property (nonatomic, copy) void 
	(^clickEventViewsBlock)(UIView *eventView); 
	eventView 是hitTest方法查找到的view。
	
	缺点：1.只要headerView稍微复杂点，点击事件就非常难以处理。
	     2.左右滑动的View过多时，在内存中均无法释放。
	
	而我的修改就是为了解决这两个问题，事件点击是最关键的。
	

### 一、点击事件的处理
	
点击难以处理主要是，作者为了实现该效果，重写hitTest方法，导致了headerView响应者链条的断裂，
虽然作者提供了一个block回调，但对于点击处理无疑是反人类。我的想法是在点击处理时将响应者链条接
起来。


1.[响应者链条](http://www.jianshu.com/p/2c5678c659d5)可以看看该文章 以下是摘抄：

	iOS使用“命中测试”（hit-testing）去寻找触摸发生下的view。命中测试会执行检测判断
	是否改触摸点发生在某个具体的view的相对边界之内。如果检测是的，它就会递归的去检测该view的
	所有子view。该view的层级最底端view包含触摸点，它就成为了“命中测试view”。之后iOS就会决
	定谁是命中测试view,并且递交触摸事件给它处理.
	
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
	
	
### 二、左右滑动的View过多时的内存问题（一般情况也用不着）
	
	
	/／ 缓存视图数 默认是 3
	@property (nonatomic, assign) CGFloat maxCacheCout;
	该属性是最大的View引用数，超过的会释放回收。
	
	一个界面的展现，分为数据和视图，其中大部分内存为视图所占用，我们只需要保存界面数据，和离开
	界面时的位置，下次创建时还原即可，不过视图的创建和释放都是比较耗性能的，会卡顿主线程。
	
	
### 三、单独下拉刷新的问题
	
	    这种设计视图在刷新处理上有两种方式：一是整体刷新，二是单独刷新。需要更具适用场景进行
    选择。关于整体刷新本框架无法使用常规的刷新控件处理，如需要可以仿微信朋友圈那种刷新处理(会	考虑抽时间在Demo 中加入该功能示例)。而单独刷新则需要对刷新控件做一下处理来实现。
    
    	刷新框架都是监听 UIScrollView 的 contentOffset 来作出响应的处理。本框架为了实现
    刷新功能做了些处理，同时也需要三方框架做一些配和。Demo中对 SVPullToRefresh 做出了一些	修改，你如果使用的是其它刷新框架，可参照做出相应的修改。
    
    1.HHHorizontalPagingView 的 allowPullToRefresh 属性设置YES。
    2.在开始刷新和结束刷新时需要 通知 HHHorizontalPagingView
    
    __weak typeof(self)weakSelf = self;
    [self.tableView addPullToRefreshOffset:self.pullOffset withActionHandler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kHHHorizontalScrollViewRefreshStartNotification object:weakSelf.tableView userInfo:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHHHorizontalScrollViewRefreshEndNotification object:weakSelf.tableView userInfo:nil];
        });
    }];
    
    3.HHHorizontalPagingView 如果网络不佳，在切换到其它界面时，刷新还未完成应当如何处理。
    考虑到切换到其它界面后，再回来headView的位置是不确定的，最好是切到其它位置后将刷新动画
    收回，监听以下通知即可。
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeBack:) name:kHHHorizontalTakeBackRefreshEndNotification object:self.tableView];
    
    - (void)takeBack:(NSNotification *)noti{
    [self.tableView.pullToRefreshView stopAnimating:NO];
    }
	
	
	4.SVPullToRefresh 的改动
	4.1 直接使用SVPullToRefresh 刷新，有个糟糕收回偏移，查看源码是 originalTopInset 偏
	移导致，故修改提供一个新的外接方法。
	- (void)addPullToRefreshOffset:(CGFloat)offset withActionHandler:(void (^)(void))actionHandler {
    
    if(!self.pullToRefreshView) {
        SVPullToRefreshView *view = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, -SVPullToRefreshViewHeight, self.bounds.size.width, SVPullToRefreshViewHeight)];
        view.pullToRefreshActionHandler = actionHandler;
        view.pullOffset = offset;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top + offset;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
	}

	传入的 offset 可通过  HHHorizontalPagingView 的 pullOffset 属性获取。造成的原因
	是为了留出 headerView的位置，传入的scrollView均做了一个偏移处理。
	
	4.2 调用 triggerPullToRefresh 失效 该问题也是偏移导致的修改如下：
	- (void)startAnimating:(BOOL)animated {
    
    CGFloat offset = self.scrollView.contentOffset.y+self.pullOffset;
    if(fequalzero(offset)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height + self.scrollView.contentOffset.y) animated:animated];
        self.wasTriggeredByUser = NO;
    }
    else{
        self.wasTriggeredByUser = YES;
    }
    self.state = SVPullToRefreshStateLoading;
	}
	
	
### 四、整体下拉刷新 － 微信朋友圈
    
    	考虑到本框架，需要左右滑动上下滚动，如果做成常规下拉悬停的刷新方式成本较高，故采用
    微信朋友圈的刷新方式处理。这类轮子不少，我就直接找了个轮子改改哈。Demo中的
    SDTimeLineRefreshHeader是从 GSD_WeiXin 中拉出的。
        刷新框架基本都是为UIScrollView 写的，但实际使用只是监听了 contentOffset 再加上
    isDragging 属性判断用户是否放手。我在 HHHorizontalPagingView 加了这两个属性在相应
    地方做了处理，然后就可以直接使用 SDTimeLineRefreshHeader 了。
    
    注意：
    1.//以下属性 用strong 是为了移除监听时scrollView 不为空，注意循环引用。
	@property (nonatomic, strong) UIView<ArtRefreshViewProtocol> *scrollView;
	
	2.添加
	self.refreshHeader = [SDTimeLineRefreshHeader refreshHeaderWithCenter:CGPointMake(40, -15)];
    
    self.refreshHeader.scrollView = (UIView<ArtRefreshViewProtocol> *)self.pagingView;
    __weak typeof(_refreshHeader) weakHeader = self.refreshHeader;
    
    // 1. 加在superview上 避免出现循环引用。
    // 2. 加在superview上 保证 refreshHeader 在 self.pagingView 上方。
    [self.pagingView.superview addSubview:self.refreshHeader];
    
    [self.refreshHeader setRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakHeader endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
    }];

    

	

	
	
	
	

	
	
	
	
