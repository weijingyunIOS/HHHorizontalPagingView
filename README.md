# HHHorizontalPagingView
对HHHorizontalPagingView的优化，解决headerView 的点击痛点

![演示](http://imgdata.hoop8.com/1605/0341929188787.gif)

我的这个是针对[Huanhoo/HHHorizontalPagingView](https://github.com/Huanhoo/HHHorizontalPagingView)的修改，HHHorizontalPagingView是一个实现上下滚动时菜单悬停在顶端，并且可以左右滑动切换的视图，实现思路非常巧妙：
	
	HHHorizontalPagingView 通过重写 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event方法将headerView 上的响应作用在了 self.currentScrollView (当前展现的scrollerView)上，