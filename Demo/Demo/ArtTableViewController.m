//
//  ArtTableViewController.m
//  Demo
//
//  Created by weijingyun on 16/5/28.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ArtTableViewController.h"
#import "SVPullToRefresh.h"
#import "JYPagingView.h"

@interface ArtTableViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation ArtTableViewController

- (void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242./255. green:242./255. blue:242./255. alpha:1.0];
    self.view = self.tableView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (!self.allowPullToRefresh) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self.tableView addPullToRefreshOffset:self.pullOffset withActionHandler:^{
        weakSelf.isRefresh = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHHHorizontalScrollViewRefreshStartNotification object:weakSelf.tableView userInfo:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf.isRefresh) {
                return;
            }
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            weakSelf.isRefresh = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kHHHorizontalScrollViewRefreshEndNotification object:weakSelf.tableView userInfo:nil];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!self.isRefresh) {
        return;
    }
    self.isRefresh = NO;
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%tu----%@----%@",self.index,@(indexPath.section),@(indexPath.row)];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.index % 2 ? 50 : 2;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    // 通过最后一个 Footer 来补高度
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return [self automaticHeightForTableView:tableView];
    }
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (CGFloat)automaticHeightForTableView:(UITableView *)tableView{
    
      // 36 是 segmentButtons 的高度 20 是segmentTopSpace的高度
    CGFloat height = 36.f + 20.f;
    
    NSInteger section = [tableView.dataSource numberOfSectionsInTableView:tableView];
    for (int i = 0; i < section; i ++) {
        
        if ([tableView.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
            height += [tableView.delegate tableView:tableView heightForHeaderInSection:i];
        }
        
        NSInteger row = [tableView.dataSource tableView:tableView numberOfRowsInSection:i];
        for (int j= 0 ; j < row; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            if ([tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                height += [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
            }
            
            if (height >= tableView.frame.size.height) {
                return 0.0001;
            }
        }
        
        if (i != section - 1) {
            
            if ([tableView.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
                height += [tableView.delegate tableView:tableView heightForFooterInSection:i];
            }
        }
        
    }
    
    if (height >= tableView.frame.size.height) {
        return 0.0001;
    }
    
    return tableView.frame.size.height - height;
}

@end
