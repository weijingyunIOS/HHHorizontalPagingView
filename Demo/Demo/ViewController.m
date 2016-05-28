//
//  ViewController.m
//  Demo
//
//  Created by weijingyun on 16/5/28.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ViewController.h"
#import "JYPagingView.h"
#import "HHContentTableView.h"

@interface ViewController ()<HHHorizontalPagingViewDelegate>

@property (nonatomic, strong) HHHorizontalPagingView *pagingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pagingView.segmentTopSpace = 20.;
    [self.pagingView reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  HHHorizontalPagingViewDelegate
// 下方左右滑UIScrollView设置
- (NSInteger)numberOfSectionsInPagingView:(HHHorizontalPagingView *)pagingView{
    return 5;
}

- (UIScrollView *)pagingView:(HHHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index{
    return [HHContentTableView contentTableViewIndex:index];
}

//headerView 设置
- (CGFloat)headerHeightInPagingView:(HHHorizontalPagingView *)pagingView{
    return 350;
}

- (UIView *)headerViewInPagingView:(HHHorizontalPagingView *)pagingView{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor orangeColor];
    return view;
}

//segmentButtons
- (CGFloat)segmentHeightInPagingView:(HHHorizontalPagingView *)pagingView{
    return 44;
}

- (NSArray<UIButton*> *)segmentButtonsInPagingView:(HHHorizontalPagingView *)pagingView{
    
    NSMutableArray *buttonArray = [NSMutableArray array];
    for(int i = 0; i < 6; i++) {
        UIButton *segmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [segmentButton setBackgroundImage:[UIImage imageNamed:@"Home_title_line"] forState:UIControlStateNormal];
        [segmentButton setBackgroundImage:[UIImage imageNamed:@"Home_title_line_select"] forState:UIControlStateSelected];
        [segmentButton setTitle:[NSString stringWithFormat:@"view%@",@(i)] forState:UIControlStateNormal];
        [segmentButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [buttonArray addObject:segmentButton];
    }
    return [buttonArray copy];
}

// 点击segment
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelected:(UIButton *)item atIndex:(NSInteger)selectedIndex{

}

- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelectedSameItem:(UIButton *)item atIndex:(NSInteger)selectedIndex{

}

// 监听当前的scrollView
- (void)pagingView:(HHHorizontalPagingView*)pagingView scrollViewDidScroll:(UIScrollView *)scrollView{

}

#pragma mark - 懒加载
- (HHHorizontalPagingView *)pagingView{
    if (!_pagingView) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pagingView = [[HHHorizontalPagingView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        [self.view addSubview:_pagingView];
    }
    return _pagingView;
}

@end
