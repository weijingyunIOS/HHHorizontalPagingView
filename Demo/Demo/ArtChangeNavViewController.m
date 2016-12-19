//
//  ArtChangeNavViewController.m
//  Demo
//
//  Created by weijingyun on 16/10/21.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ArtChangeNavViewController.h"
#import "JYPagingView.h"
#import "ArtTableViewController.h"

@interface ArtChangeNavViewController ()<HHHorizontalPagingViewDelegate>

@property (nonatomic, strong) HHHorizontalPagingView *pagingView;

@property (nonatomic, strong) UIView *navView;


@end

@implementation ArtChangeNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //     Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:242./255. green:242./255. blue:242./255. alpha:1.0];
    [self.pagingView reload];
    
    
    self.navView = [[UIView alloc] init];
    [self.view addSubview:self.navView];
    self.navView.backgroundColor = [UIColor colorWithWhite:1 alpha: 0];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.navView.frame = CGRectMake(0, 0, size.width, 84);
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showText:(NSString *)str{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate: self  cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
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
    vc.fillHight = self.pagingView.segmentTopSpace + 36;
    return (UIScrollView *)vc.view;
}

//headerView 设置
- (CGFloat)headerHeightInPagingView:(HHHorizontalPagingView *)pagingView{
    return 250;
}

- (UIView *)headerViewInPagingView:(HHHorizontalPagingView *)pagingView{
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor orangeColor];
    return headerView;
}

- (void)but1Click{
    NSLog(@"%s",__func__);
    [self showText:@"but1Click"];
}

- (void)but2Click{
    NSLog(@"%s",__func__);
    [self showText:@"but2Click"];
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
        NSString *str = i == 5 ? @"返回" : [NSString stringWithFormat:@"view%@",@(i)];
        [segmentButton setTitle:str forState:UIControlStateNormal];
        [segmentButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        segmentButton.adjustsImageWhenHighlighted = NO;
        [buttonArray addObject:segmentButton];
    }
    return [buttonArray copy];
}

// 点击segment
- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelected:(UIButton *)item atIndex:(NSInteger)selectedIndex{
    NSLog(@"%s",__func__);
    if (selectedIndex == 5) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)pagingView:(HHHorizontalPagingView*)pagingView segmentDidSelectedSameItem:(UIButton *)item atIndex:(NSInteger)selectedIndex{
    NSLog(@"%s",__func__);
    
}

// 视图切换完成时调用
- (void)pagingView:(HHHorizontalPagingView*)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex{
    NSLog(@"%s \n %tu  to  %tu",__func__,aIndex,toIndex);
}

- (void)pagingView:(HHHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset {


    if (offset >= -84 - 36) { // > 0 代表已经只顶了
        return;
    }
    
    CGFloat fm = self.pagingView.pullOffset - 84.0 - 36;
    CGFloat fz = - 84 - 36 - offset;
    float al = 1.0 - fz / fm;
    al = al <= 0.05 ? 0 : al;
    al = al >= 0.95 ? 1 : al;
       NSLog(@"__ %f  __  %f __ %lf",offset,self.pagingView.pullOffset, al);
    self.navView.backgroundColor = [UIColor colorWithWhite:1 alpha: al];
    
}

#pragma mark - 懒加载
- (HHHorizontalPagingView *)pagingView{
    if (!_pagingView) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pagingView = [[HHHorizontalPagingView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pagingView.segmentTopSpace = 84.;
        _pagingView.segmentView.backgroundColor = [UIColor colorWithRed:242./255. green:242./255. blue:242./255. alpha:1.0];
        _pagingView.maxCacheCout = 5.;
        _pagingView.isGesturesSimulate = YES;
        [self.view addSubview:_pagingView];
    }
    return _pagingView;
}

@end
