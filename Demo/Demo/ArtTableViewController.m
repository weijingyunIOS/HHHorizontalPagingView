//
//  ArtTableViewController.m
//  Demo
//
//  Created by weijingyun on 16/5/28.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ArtTableViewController.h"

@interface ArtTableViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

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
    
    return self.index % 2 ? 20 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return [self automaticHeight];
    }
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (CGFloat)automaticHeight{
    
    CGFloat height = 0.;
    NSInteger section = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
    for (int i = 0; i < section; i ++) {
        
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
            height += [self.tableView.delegate tableView:self.tableView heightForHeaderInSection:section];
        }
        
        NSInteger row = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:section];
        for (int j= 0 ; j < row; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                height += [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:indexPath];
            }
            
            if (height >= self.tableView.frame.size.height) {
                return 0.0001;
            }
        }
        
        if (i != section - 1) {
            
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
                height += [self.tableView.delegate tableView:self.tableView heightForFooterInSection:section];
            }
        }
        
    }
    
    if (height >= self.tableView.frame.size.height) {
        return 0.0001;
    }
    
    return self.tableView.frame.size.height - height - 36;
}

@end
