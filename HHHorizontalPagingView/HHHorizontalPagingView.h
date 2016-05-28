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
// 点击segment
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelected:(UIButton *)item atIndex:(NSInteger)selectedIndex;
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelectedSameItem:(UIButton *)item atIndex:(NSInteger)selectedIndex;

// 监听当前的scrollView
- (void)pagingView:(HHHorizontalPagingView*)pagingView scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@class HHSegmentView;

@interface HHHorizontalPagingView : UIView

/**
 *  segment据顶部的距离
 */
@property (nonatomic, assign) CGFloat segmentTopSpace;

/**
 *  自定义segmentButton的size
 */
@property (nonatomic, assign) CGSize segmentButtonSize;

/**
 *  下拉时如需要放大，则传入的图片的上边距约束，默认为不放大
 */
@property (nonatomic, strong) NSLayoutConstraint *magnifyTopConstraint;

/**
 *  切换视图
 */
@property (nonatomic, strong, readonly) UIView *segmentView;

/**
 *  视图切换的回调block
 */
@property (nonatomic, copy) void (^pagingViewSwitchBlock)(NSInteger switchIndex);

/**
 *  视图点击的回调block
 */
@property (nonatomic, copy) void (^clickEventViewsBlock)(UIView *eventView);

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

- (void)reload;

@end
