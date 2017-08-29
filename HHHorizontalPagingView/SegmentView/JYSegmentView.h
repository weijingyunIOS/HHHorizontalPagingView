//
//  JYSegmentView.h
//  Demo
//
//  Created by weijingyun on 2017/8/29.
//  Copyright © 2017年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYSegmentView : UIView

@property (nonatomic, copy) void(^clickBlock)(UIButton *but);
@property (nonatomic, assign) CGFloat             segmentBarHeight;
@property (nonatomic, assign) CGSize              segmentButtonSize;
@property (nonatomic, strong) NSArray            *segmentButtons;
@property (nonatomic, assign) NSInteger            currenPage; // 当前页

- (void)configureSegmentButtonLayout;

@end
