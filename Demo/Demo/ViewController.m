//
//  ViewController.m
//  Demo
//
//  Created by weijingyun on 16/5/28.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ViewController.h"
#import "JYPagingView.h"
#import "ArtTableViewController.h"

@interface ViewController ()<HHHorizontalPagingViewDelegate>

@property (nonatomic, strong) HHHorizontalPagingView *pagingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    ArtTableViewController *vc = [[ArtTableViewController alloc] init];
    [self addChildViewController:vc];
    vc.index = index;
    return (UIScrollView *)vc.view;
}

//headerView 设置
- (CGFloat)headerHeightInPagingView:(HHHorizontalPagingView *)pagingView{
    return 250;
}

- (UIView *)headerViewInPagingView:(HHHorizontalPagingView *)pagingView{
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor orangeColor];
    [headerView whenTapped:^{
        NSLog(@"1111111111");
    }];
    
    UIView *view = [[UIView alloc] init];
    [headerView addSubview:view];
    view.backgroundColor = [UIColor redColor];
    view.frame = CGRectMake(0, 0, 100, 200);
    view.tag = 1000;
    
    [view whenTapped:^{
        NSLog(@"2222222222");
    }];
    
    UIView *view1 = [[UIView alloc] init];
    [view addSubview:view1];
    view1.tag = 1001;
    view1.backgroundColor = [UIColor grayColor];
    view1.frame = CGRectMake(50, 50, 50, 100);
    
    
    [view1 whenTapped:^{
        NSLog(@"3333333333");
    }];
    
    return headerView;
}

//segmentButtons
- (CGFloat)segmentHeightInPagingView:(HHHorizontalPagingView *)pagingView{
    return 36.;
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
        _pagingView.segmentTopSpace = 20;
        _pagingView.segmentView.backgroundColor = [UIColor colorWithRed:242./255. green:242./255. blue:242./255. alpha:1.0];
//        _pagingView.maxCacheCout = 5.;
        [self.view addSubview:_pagingView];
    }
    return _pagingView;
}

@end
