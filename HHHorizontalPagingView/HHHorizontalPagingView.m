//
//  HHHorizontalPagingView.m
//  HHHorizontalPagingView
//
//  Created by Huanhoo on 15/7/16.
//  Copyright (c) 2015年 Huanhoo. All rights reserved.
//

#import "HHHorizontalPagingView.h"
#import "UIView+WhenTappedBlocks.h"

@interface DynamicItem : NSObject<UIDynamicItem>
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;
@end

@implementation DynamicItem
- (instancetype)init {
    if (self = [super init]) {
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}
@end

@interface HHHorizontalPagingView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView             *headerView;
@property (nonatomic, strong) NSArray            *segmentButtons;
@property (nonatomic, strong) NSMutableArray<UIScrollView *>*contentViewArray;

@property (nonatomic, strong, readwrite) UIView  *segmentView;

@property (nonatomic, strong) UICollectionView   *horizontalCollectionView;

@property (nonatomic, weak)   UIScrollView       *currentScrollView;
@property (nonatomic, strong) NSLayoutConstraint *headerOriginYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *headerSizeHeightConstraint;
@property (nonatomic, assign) CGFloat            headerViewHeight;
@property (nonatomic, assign) CGFloat            segmentBarHeight;
@property (nonatomic, assign) BOOL               isSwitching;

@property (nonatomic, strong) NSMutableArray     *segmentButtonConstraintArray;

@property (nonatomic, strong) UIView             *currentTouchView;
@property (nonatomic, assign) CGPoint            currentTouchViewPoint;
@property (nonatomic, strong) UIButton           *currentTouchButton;

@property (nonatomic, strong) UIDynamicAnimator  *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *inertialBehavior;

/**
 *  代理
 */
@property (nonatomic, weak) id<HHHorizontalPagingViewDelegate> delegate;

@end

@implementation HHHorizontalPagingView

static void *HHHorizontalPagingViewScrollContext = &HHHorizontalPagingViewScrollContext;
static void *HHHorizontalPagingViewInsetContext  = &HHHorizontalPagingViewInsetContext;
static void *HHHorizontalPagingViewPanContext    = &HHHorizontalPagingViewPanContext;
static NSString *pagingCellIdentifier            = @"PagingCellIdentifier";
static NSInteger pagingButtonTag                 = 1000;
static NSInteger pagingScrollViewTag             = 2000;

#pragma mark - HHHorizontalPagingView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HHHorizontalPagingViewDelegate>) delegate{
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        // UICollectionView
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing          = 0.0;
        layout.minimumInteritemSpacing     = 0.0;
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        self.horizontalCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [self.horizontalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:pagingCellIdentifier];
        self.horizontalCollectionView.backgroundColor                = [UIColor clearColor];
        self.horizontalCollectionView.dataSource                     = self;
        self.horizontalCollectionView.delegate                       = self;
        self.horizontalCollectionView.pagingEnabled                  = YES;
        self.horizontalCollectionView.showsHorizontalScrollIndicator = NO;
        self.horizontalCollectionView.scrollsToTop                   = NO;
        UICollectionViewFlowLayout *tempLayout = (id)self.horizontalCollectionView.collectionViewLayout;
        tempLayout.itemSize = self.horizontalCollectionView.frame.size;
        [self addSubview:self.horizontalCollectionView];
        [self configureHeaderView];
        [self configureSegmentView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    }
    return self;
}

- (void)reload{
    self.headerView                  = [self.delegate headerViewInPagingView:self];
    self.headerViewHeight            = [self.delegate headerHeightInPagingView:self];
    self.segmentButtons              = [self.delegate segmentButtonsInPagingView:self];
    self.segmentBarHeight            = [self.delegate segmentHeightInPagingView:self];
    [self configureHeaderView];
    [self configureSegmentView];
    // 防止不友好动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.horizontalCollectionView reloadData];
    });
}

- (void)scrollToIndex:(NSInteger)pageIndex {
    [self segmentButtonEvent:self.segmentButtons[pageIndex]];
}

- (void)scrollEnable:(BOOL)enable {
    if(enable) {
        self.segmentView.userInteractionEnabled     = YES;
        self.horizontalCollectionView.scrollEnabled = YES;
    }else {
        self.segmentView.userInteractionEnabled     = NO;
        self.horizontalCollectionView.scrollEnabled = NO;
    }
}

- (void)configureHeaderView {
    [self.headerView removeFromSuperview];
    if(self.headerView) {
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        self.headerOriginYConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:self.headerOriginYConstraint];
        
        self.headerSizeHeightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.headerViewHeight];
        [self.headerView addConstraint:self.headerSizeHeightConstraint];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.headerView addGestureRecognizer:pan];
    }
}

- (void)pan:(UIPanGestureRecognizer*)pan{
    
    CGPoint point = [pan translationInView:self.headerView];
    [self rollingPointy:point.y];
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        
        CGPoint contentOffset = self.currentScrollView.contentOffset;
        CGFloat border = - self.headerViewHeight - [self.delegate segmentHeightInPagingView:self];
        if (contentOffset.y <= border) {
            [UIView animateWithDuration:0.35 animations:^{
                self.currentScrollView.contentOffset = CGPointMake(contentOffset.x, -286);
                [self layoutIfNeeded];
            }];
        }else{
            CGFloat velocity = [pan velocityInView:self.headerView].y;
            [self deceleratingAnimator:velocity];
        }
    }
    
    // 清零防止偏移累计
    [pan setTranslation:CGPointZero inView:self.headerView];
    
}

- (void)rollingPointy:(CGFloat)pointy{
    
    CGPoint contentOffset = self.currentScrollView.contentOffset;
    CGFloat border = - self.headerViewHeight - [self.delegate segmentHeightInPagingView:self];
    CGFloat offsety = contentOffset.y - pointy * (1/contentOffset.y * border * 0.8);
    self.currentScrollView.contentOffset = CGPointMake(contentOffset.x, offsety);
}

- (void)deceleratingAnimator:(CGFloat)velocity{
    
    if (self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
    }
    DynamicItem *item = [[DynamicItem alloc] init];
    item.center = CGPointMake(0, 0);
    // velocity是在手势结束的时候获取的竖直方向的手势速度
    UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ item ]];
    [inertialBehavior addLinearVelocity:CGPointMake(0, velocity * 0.025) forItem:item];
    // 通过尝试取2.0比较像系统的效果
    inertialBehavior.resistance = 2;
    
    __weak typeof(self)weakSelf = self;
    inertialBehavior.action = ^{
        CGPoint contentOffset = self.currentScrollView.contentOffset;
        CGFloat speed = [weakSelf.inertialBehavior linearVelocityForItem:item].y;
        CGFloat offset = contentOffset.y -  speed;
        if (speed >= -0.2) {
            [weakSelf.animator removeBehavior:weakSelf.inertialBehavior];
            weakSelf.inertialBehavior = nil;
        }else if (offset + self.frame.size.height >= weakSelf.currentScrollView.contentSize.height){
            [weakSelf.animator removeBehavior:weakSelf.inertialBehavior];
            weakSelf.inertialBehavior = nil;
            offset = self.currentScrollView.contentSize.height - self.currentScrollView.bounds.size.height;
            self.currentScrollView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y - velocity * 0.05);
            [UIView animateWithDuration:0.5 animations:^{
                self.currentScrollView.contentOffset = CGPointMake(contentOffset.x, offset);
                [self layoutIfNeeded];
            }];
            
        }else{
            self.currentScrollView.contentOffset = CGPointMake(contentOffset.x, offset);
        }
    };
    self.inertialBehavior = inertialBehavior;
    [self.animator addBehavior:inertialBehavior];
}

- (UIDynamicAnimator *)animator{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] init];
    }
    return _animator;
}

- (void)configureSegmentView {
    [self.segmentView removeFromSuperview];
    self.segmentView = nil;
    if(self.segmentView) {
        self.segmentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.segmentView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView ? : self attribute:self.headerView ? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.segmentView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.segmentBarHeight]];
    }
}

- (UIScrollView *)scrollViewAtIndex:(NSInteger)index{
    
    __block UIScrollView *scrollView = nil;
    [self.contentViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == pagingScrollViewTag + index) {
            scrollView = obj;
            *stop = YES;
        }
    }];

    if (scrollView == nil) {
        scrollView = [self.delegate pagingView:self viewAtIndex:index];
        [self configureContentView:scrollView];
        scrollView.tag = pagingScrollViewTag + index;
        [self.contentViewArray addObject:scrollView];
    }
    return scrollView;
}

- (void)configureContentView:(UIScrollView *)scrollView{
    [scrollView  setContentInset:UIEdgeInsetsMake(self.headerViewHeight+self.segmentBarHeight, 0., scrollView.contentInset.bottom, 0.)];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentOffset = CGPointMake(0., -self.headerViewHeight-self.segmentBarHeight);
    [scrollView.panGestureRecognizer addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&HHHorizontalPagingViewPanContext];
    [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&HHHorizontalPagingViewScrollContext];
    [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&HHHorizontalPagingViewInsetContext];
    if (scrollView == nil) {
        self.currentScrollView = scrollView;
    }
}

- (UIView *)segmentView {
    if(!_segmentView) {
        _segmentView = [[UIView alloc] init];
        [self configureSegmentButtonLayout];
    }
    return _segmentView;
}

- (void)configureSegmentButtonLayout {
    if([self.segmentButtons count] > 0) {
        
        CGFloat buttonTop    = 0.f;
        CGFloat buttonLeft   = 0.f;
        CGFloat buttonWidth  = 0.f;
        CGFloat buttonHeight = 0.f;
        if(CGSizeEqualToSize(self.segmentButtonSize, CGSizeZero)) {
            buttonWidth = [[UIScreen mainScreen] bounds].size.width/(CGFloat)[self.segmentButtons count];
            buttonHeight = self.segmentBarHeight;
        }else {
            buttonWidth = self.segmentButtonSize.width;
            buttonHeight = self.segmentButtonSize.height;
            buttonTop = (self.segmentBarHeight - buttonHeight)/2.f;
            buttonLeft = ([[UIScreen mainScreen] bounds].size.width - ((CGFloat)[self.segmentButtons count]*buttonWidth))/((CGFloat)[self.segmentButtons count]+1);
        }
        
        [_segmentView removeConstraints:self.segmentButtonConstraintArray];
        for(int i = 0; i < [self.segmentButtons count]; i++) {
            UIButton *segmentButton = self.segmentButtons[i];
            [segmentButton removeConstraints:self.segmentButtonConstraintArray];
            segmentButton.tag = pagingButtonTag+i;
            [segmentButton addTarget:self action:@selector(segmentButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
            [_segmentView addSubview:segmentButton];
            
            if(i == 0) {
                [segmentButton setSelected:YES];
            }
            
            segmentButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_segmentView attribute:NSLayoutAttributeTop multiplier:1 constant:buttonTop];
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_segmentView attribute:NSLayoutAttributeLeft multiplier:1 constant:i*buttonWidth+buttonLeft*i+buttonLeft];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth];
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:segmentButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
            
            [self.segmentButtonConstraintArray addObject:topConstraint];
            [self.segmentButtonConstraintArray addObject:leftConstraint];
            [self.segmentButtonConstraintArray addObject:widthConstraint];
            [self.segmentButtonConstraintArray addObject:heightConstraint];
            
            [_segmentView addConstraint:topConstraint];
            [_segmentView addConstraint:leftConstraint];
            [segmentButton addConstraint:widthConstraint];
            [segmentButton addConstraint:heightConstraint];
            
            if (segmentButton.currentImage) {
                 CGFloat imageWidth = segmentButton.imageView.bounds.size.width;
                 CGFloat labelWidth = segmentButton.titleLabel.bounds.size.width;
                 segmentButton.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + 5, 0, -labelWidth);
                 segmentButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
            }
        }
        
    }
}

- (void)segmentButtonEvent:(UIButton *)segmentButton {
    
    NSInteger clickIndex = segmentButton.tag-pagingButtonTag;
    if (clickIndex >= [self.delegate numberOfSectionsInPagingView:self]) {
        if ([self.delegate respondsToSelector:@selector(pagingView:segmentDidSelected:atIndex:)]) {
            [self.delegate pagingView:self segmentDidSelected:segmentButton atIndex:clickIndex];
        }
        return;
    }
    
    if (segmentButton.selected) {
        if ([self.delegate respondsToSelector:@selector(pagingView:segmentDidSelectedSameItem:atIndex:)]) {
            [self.delegate pagingView:self segmentDidSelectedSameItem:segmentButton atIndex:clickIndex];
        }
    }else{
        for(UIButton *b in self.segmentButtons) {
            [b setSelected:NO];
        }
        [segmentButton setSelected:YES];
        
        if ([self.delegate respondsToSelector:@selector(pagingView:segmentDidSelected:atIndex:)]) {
            [self.delegate pagingView:self segmentDidSelected:segmentButton atIndex:clickIndex];
        }
    }
    
    [self.horizontalCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:clickIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    if(self.currentScrollView.contentOffset.y<-(self.headerViewHeight+self.segmentBarHeight)) {
        [self.currentScrollView setContentOffset:CGPointMake(self.currentScrollView.contentOffset.x, -(self.headerViewHeight+self.segmentBarHeight)) animated:NO];
    }else {
        [self.currentScrollView setContentOffset:self.currentScrollView.contentOffset animated:NO];
    }
    self.currentScrollView = [self scrollViewAtIndex:clickIndex];
    [self removeCacheScrollView];
    if(self.pagingViewSwitchBlock) {
        self.pagingViewSwitchBlock(clickIndex);
    }
}

- (void)adjustContentViewOffset {
    self.isSwitching = YES;
    CGFloat headerViewDisplayHeight = self.headerViewHeight + self.headerView.frame.origin.y;
    [self.currentScrollView layoutIfNeeded];
    
    if (headerViewDisplayHeight != self.segmentTopSpace) {// 还原位置
        [self.currentScrollView setContentOffset:CGPointMake(0, -headerViewDisplayHeight - self.segmentBarHeight)];
    }else if(self.currentScrollView.contentOffset.y < -self.segmentBarHeight) {
        [self.currentScrollView setContentOffset:CGPointMake(0, -headerViewDisplayHeight-self.segmentBarHeight)];
    }else {
        // self.segmentTopSpace
        [self.currentScrollView setContentOffset:CGPointMake(0, self.currentScrollView.contentOffset.y-headerViewDisplayHeight + self.segmentTopSpace)];
    }
    
    if ([self.currentScrollView.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.currentScrollView.delegate scrollViewDidEndDragging:self.currentScrollView willDecelerate:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0)), dispatch_get_main_queue(), ^{
        self.isSwitching = NO;
    });
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    
    if (self.inertialBehavior) {
        [self.animator removeBehavior:self.inertialBehavior];
    }
    
    if(point.x < 10) {
        return NO;
    }
    return YES;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if ([view isDescendantOfView:self.headerView] || [view isDescendantOfView:self.segmentView]) {
//        self.horizontalCollectionView.scrollEnabled = NO;
//        
//        self.currentTouchView = nil;
//        self.currentTouchButton = nil;
//        
//        [self.segmentButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if(obj == view) {
//                self.currentTouchButton = obj;
//            }
//        }];
//        if(!self.currentTouchButton) {
//            self.currentTouchView = view;
//            self.currentTouchViewPoint = [self convertPoint:point toView:self.currentTouchView];
//        }else {
//            return view;
//        }
//        return self.currentScrollView;
//    }
//    return view;
//}

#pragma mark - Setter
- (void)setSegmentButtonSize:(CGSize)segmentButtonSize {
    _segmentButtonSize = segmentButtonSize;
    [self configureSegmentButtonLayout];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.delegate numberOfSectionsInPagingView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isSwitching = YES;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pagingCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    for(UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    UIScrollView *v = [self scrollViewAtIndex:indexPath.row];
    [cell.contentView addSubview:v];
    CGFloat scrollViewHeight = v.frame.size.height;
    v.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:scrollViewHeight == 0 ? 0 : -(cell.contentView.frame.size.height-v.frame.size.height)]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    self.currentScrollView = v;
    [self adjustContentViewOffset];
    return cell;
    
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(__unused id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if(context == &HHHorizontalPagingViewPanContext) {
        
        self.horizontalCollectionView.scrollEnabled = YES;
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        //failed说明是点击事件
        if(state == UIGestureRecognizerStateFailed) {
            if(self.currentTouchButton) {
                [self segmentButtonEvent:self.currentTouchButton];
            }else if(self.currentTouchView) {
                [self.currentTouchView viewWasTappedPoint:self.currentTouchViewPoint];
                if (self.clickEventViewsBlock) {
                    self.clickEventViewsBlock(self.currentTouchView);
                }
            }
            self.currentTouchView = nil;
            self.currentTouchButton = nil;
        }
        
    }else if (context == &HHHorizontalPagingViewScrollContext) {
        self.currentTouchView = nil;
        self.currentTouchButton = nil;
        if (self.isSwitching) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(pagingView:scrollViewDidScroll:)]) {
            [self.delegate pagingView:self scrollViewDidScroll:self.currentScrollView];
        }
        
        CGFloat oldOffsetY          = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        CGFloat newOffsetY          = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        CGFloat deltaY              = newOffsetY - oldOffsetY;
        
        CGFloat headerViewHeight    = self.headerViewHeight;
        CGFloat headerDisplayHeight = self.headerViewHeight+self.headerOriginYConstraint.constant;
        
        if(deltaY >= 0) {    //向上滚动
            
            if(headerDisplayHeight - deltaY <= self.segmentTopSpace) {
                self.headerOriginYConstraint.constant = -headerViewHeight+self.segmentTopSpace;
            }else {
                self.headerOriginYConstraint.constant -= deltaY;
            }
            if(headerDisplayHeight <= self.segmentTopSpace) {
                self.headerOriginYConstraint.constant = -headerViewHeight+self.segmentTopSpace;
            }
            
            if (self.headerOriginYConstraint.constant >= 0 && self.magnifyTopConstraint) {
                self.magnifyTopConstraint.constant = -self.headerOriginYConstraint.constant;
            }
            
        }else {            //向下滚动
            
            if (headerDisplayHeight+self.segmentBarHeight < -newOffsetY) {
                self.headerOriginYConstraint.constant = -self.headerViewHeight-self.segmentBarHeight-self.currentScrollView.contentOffset.y;
            }
            
            if (self.headerOriginYConstraint.constant > 0 && self.magnifyTopConstraint) {
                self.magnifyTopConstraint.constant = -self.headerOriginYConstraint.constant;
            }
            
        }
    }else if(context == &HHHorizontalPagingViewInsetContext) {
        
        if(self.currentScrollView.contentOffset.y > -self.segmentBarHeight) {
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.headerOriginYConstraint.constant = -self.headerViewHeight-self.segmentBarHeight-self.currentScrollView.contentOffset.y;
            [self layoutIfNeeded];
            [self.headerView layoutIfNeeded];
            [self.segmentView layoutIfNeeded];
        }];
        
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat page = scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width;
    NSInteger currentPage = page / 1;
    if (page - currentPage > 0.5) {
        return;
    }
    
    for(UIButton *b in self.segmentButtons) {
        if(b.tag - pagingButtonTag == currentPage) {
            [b setSelected:YES];
        }else {
            [b setSelected:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width;
    for(UIButton *b in self.segmentButtons) {
        if(b.tag - pagingButtonTag == currentPage) {
            [b setSelected:YES];
        }else {
            [b setSelected:NO];
        }
    }
    self.currentScrollView = [self scrollViewAtIndex:currentPage];
    [self removeCacheScrollView];
    if(self.pagingViewSwitchBlock) {
        self.pagingViewSwitchBlock(currentPage);
    }
}

- (void)removeCacheScrollView{
    if (self.contentViewArray.count <= self.maxCacheCout) {
        return;
    }
    while (self.contentViewArray.count > self.maxCacheCout) {
        UIScrollView *scrollView = self.contentViewArray.firstObject;
        if (scrollView == self.currentScrollView) {
            if (self.contentViewArray.count == 1) {
                return;
            }
            scrollView = self.contentViewArray.lastObject;
        }
        [self removeScrollView:scrollView];
    }
}

- (void)releaseCache{
    [self.contentViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.currentScrollView) {
            [self removeScrollView:obj];
        }
    }];
}

- (void)removeScrollView:(UIScrollView *)scrollView{
    [self removeObserverFor:scrollView];
    [scrollView removeFromSuperview];
    [[self viewControllerForView:scrollView] removeFromParentViewController];
    [self.contentViewArray removeObject:scrollView];
}

- (UIViewController *)viewControllerForView:(UIView *)view {
    for (UIView* next = view; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)dealloc {
    [self.contentViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserverFor:obj];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObserverFor:(UIScrollView *)scrollView{
    [scrollView.panGestureRecognizer removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:&HHHorizontalPagingViewPanContext];
    [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:&HHHorizontalPagingViewScrollContext];
    [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) context:&HHHorizontalPagingViewInsetContext];
}

#pragma mark - 懒加载
- (NSMutableArray *)segmentButtonConstraintArray{
    if (!_segmentButtonConstraintArray) {
        _segmentButtonConstraintArray = [NSMutableArray array];
    }
    return _segmentButtonConstraintArray;
}

- (NSMutableArray<UIScrollView *> *)contentViewArray{
    if (!_contentViewArray) {
        _contentViewArray = [[NSMutableArray alloc] init];
    }
    return _contentViewArray;
}

- (CGFloat)maxCacheCout{
    if (_maxCacheCout == 0) {
        _maxCacheCout = 3;
    }
    return _maxCacheCout;
}

@end
