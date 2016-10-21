//
//  HHHorizontalPagingView.h
//  HHHorizontalPagingView
//
//  Created by Huanhoo on 15/7/16.
//  Copyright (c) 2015年 Huanhoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHHorizontalPagingView;

@protocol HHHorizontalPagingViewDelegate<NSObject>

// 下方左右滑UIScrollView设置
- (NSInteger)numberOfSectionsInPagingView:(HHHorizontalPagingView *)pagingView;
- (UIScrollView *)pagingView:(HHHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index;

//headerView 设置
- (CGFloat)headerHeightInPagingView:(HHHorizontalPagingView *)pagingView;
- (UIView *)headerViewInPagingView:(HHHorizontalPagingView *)pagingView;

//segmentButtons
- (CGFloat)segmentHeightInPagingView:(HHHorizontalPagingView *)pagingView;
- (NSArray<UIButton*> *)segmentButtonsInPagingView:(HHHorizontalPagingView *)pagingView;

@optional
// 非当前页点击segment
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelected:(UIButton *)item atIndex:(NSInteger)selectedIndex;
// 当前页点击segment
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelectedSameItem:(UIButton *)item atIndex:(NSInteger)selectedIndex;

// 视图切换完成时调用
- (void)pagingView:(HHHorizontalPagingView*)pagingView didiSwitchAtIndex:(NSInteger)selectedIndex;

// 监听当前的scrollView停止滚动
- (void)pagingView:(HHHorizontalPagingView*)pagingView scrollViewDidScroll:(UIScrollView *)scrollView;

/*
  与 magnifyTopConstraint 属性相对应  下拉时如需要放大，则传入的图片的上边距约束
  考虑到开发中很少使用原生约束，故放开代理方法 用于用户自行根据 偏移处理相应效果
 
  该版本将 magnifyTopConstraint 属性删除
 */
- (void)pagingView:(HHHorizontalPagingView*)pagingView scrollTopOffset:(CGFloat)offset;

@end

@class HHSegmentView;

@interface HHHorizontalPagingView : UIView

/**
 *  segment据顶部的距离
 */
@property (nonatomic, assign) CGFloat segmentTopSpace;

/**
 *  缓存视图数 默认是 3
 */
@property (nonatomic, assign) CGFloat maxCacheCout;


/**
 *  自定义segmentButton的size
 */
@property (nonatomic, assign) CGSize segmentButtonSize;


/**
 *  切换视图
 */
@property (nonatomic, strong, readonly) UIView *segmentView;


/**
 *  实例化横向分页控件
 *  @return  控件对象
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HHHorizontalPagingViewDelegate>) delegate;

/**
 *  手动控制滚动到某个视图
 *
 *  @param pageIndex 页号
 */
- (void)scrollToIndex:(NSInteger)pageIndex;

/**
 *  左右滑动
 *
 *  @param enable 是否允许滚动
 */
- (void)scrollEnable:(BOOL)enable;

/**
 *  获取当前的 UIScrollView
 *
 *  @param index 页号
 */
- (UIScrollView *)scrollViewAtIndex:(NSInteger)index;

// 进行页面刷新
- (void)reload;

// 清除视图缓存，接收到内存警告也会执行
- (void)releaseCache;

@end
