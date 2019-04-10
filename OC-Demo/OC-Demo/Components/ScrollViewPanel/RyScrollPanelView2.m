//
//  RyScrollPanelView2.m
//  SleepDoctor
//
//  Created by aHao on 2017/5/9.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import "RyScrollPanelView2.h"
@interface RyScrollPanelView2()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UIView *lastView;
@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, assign, getter=isInitiated) BOOL initiated;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, assign) BOOL flagForNoAnimated;
@property (nonatomic, assign) NSUInteger catheIndex;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation RyScrollPanelView2
- (instancetype)initWithFrame:(CGRect)frame defaultIndex:(NSUInteger)defaultIndex{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageControlInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.catheIndex = -1;
        self.selectIndex = defaultIndex;
        self.initiated = NO;
        self.flag = NO;
        self.flagForNoAnimated = NO;
        [self setupSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame defaultIndex:0];
}

- (void)setupSubView{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.firstView];
    [self.scrollView addSubview:self.secondView];
    [self.scrollView addSubview:self.lastView];
    [self addSubview:self.pageControl];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.scrollEnabled = [self vcCount] > 1;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*3, 0);
    if (!self.isInitiated && self.bounds.size.width > 0) {
        self.initiated = YES;
        [self containerView:self.secondView addSubviewAtIndex:self.selectIndex];
        [UIView animateWithDuration:0 animations:^{
            [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:NO];
        } completion:^(BOOL finished) {
            self.scrollView.delegate = self;
        }];
        self.pageControl.numberOfPages = [self vcCount];
        self.pageControl.currentPage = self.selectIndex;
    }
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
    CGFloat pageControlWidth = pageControlSize.width;
    CGFloat pageControlHeight = pageControlSize.height;
    self.pageControl.frame = CGRectMake((viewWidth-pageControlWidth)/2.0+self.pageControlInsets.left-self.pageControlInsets.right
                                        , viewHeight-pageControlHeight+self.pageControlInsets.top-self.pageControlInsets.bottom
                                        , pageControlWidth
                                        , pageControlHeight);
    [self adjustScrollViewSubView];
}

#pragma mark - public function
- (void)displayViewAtIndex:(NSUInteger)index animated:(BOOL)animated{
    if (self.selectIndex == index) {
        return;
    }
    if (!self.isInitiated) {
        self.selectIndex = index;
        return;
    }
    if (index >= [self vcCount]) {
        index = MAX(0, [self vcCount]-1);
    }
    UIView *containerView = nil;
    if (index > self.selectIndex) {
        containerView = self.lastView;
    }else{
        containerView = self.firstView;
    }
    if (containerView) {
        self.flag = YES;
        [self containerView:containerView addSubviewAtIndex:index];
        self.catheIndex = index;
        self.flagForNoAnimated = !animated;
        [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(containerView.frame), 0) animated:animated];
    }
}

- (void)reloadData{
    self.initiated = NO;
    [self layoutIfNeeded];
}

- (void)containerView:(UIView *)containerView addSubviewAtIndex:(NSUInteger)index{
    UIView *todoView = [self viewAtIndex:index];
    for (UIView *sub in containerView.subviews) {
        if (sub != todoView) {
            [sub removeFromSuperview];
        }
    }
    if (todoView && todoView.superview != containerView){
        if ([self.dataSource respondsToSelector:@selector(scrollPanelView2:viewFrameAtIndex:)]) {
            todoView.frame = [self.dataSource scrollPanelView2:self viewFrameAtIndex:index];
        }else{
            todoView.frame = containerView.bounds;
        }
        [containerView addSubview:todoView];
    }
}

- (CGFloat)normalizationProgressWithToIndex:(NSUInteger)toIndex fromIndex:(NSUInteger)fromIndex progress:(CGFloat)progress{
    NSLog(@"fromIndex: %ld toIndex: %ld progress: %f",fromIndex,toIndex,progress);
    CGFloat realProgress = 0;
    if ([self vcCount] == 0) {
        return realProgress;
    }
    if (toIndex == 0 && fromIndex == [self vcCount] - 1) {
        realProgress = ((CGFloat)fromIndex + progress)/(CGFloat)[self vcCount];
        NSLog(@"real progress: %f",realProgress);
        return realProgress;
    }
    
    if (toIndex == [self vcCount] - 1 && fromIndex == 0) {
        realProgress = ((CGFloat)[self vcCount] - progress)/(CGFloat)[self vcCount];
        NSLog(@"real progress: %f",realProgress);
        return realProgress;
    }
    
    if (toIndex > fromIndex && toIndex != 0) {
        realProgress = ((CGFloat)fromIndex + progress)/(CGFloat)[self vcCount];
    }else if(fromIndex > toIndex && toIndex != [self vcCount]-1){
        realProgress = ((CGFloat)fromIndex - progress)/(CGFloat)[self vcCount];
    }
    NSLog(@"real progress: %f",realProgress);
    return realProgress;
}

- (dispatch_source_t)timer {
    if (!_timer) {
        __block NSUInteger index = self.selectIndex;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer,DISPATCH_TIME_NOW,3.0*NSEC_PER_SEC, 0); //每3秒执行一次
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                index = index >= [self vcCount] ? 0 : index;
                [self displayViewAtIndex:index animated:false];
                index++;
            });
        });
    }
    return _timer;
}

- (void)scrollWith:(BOOL)flag{
    if (!flag) {
        dispatch_source_cancel(self.timer);
    }
    else{
        dispatch_resume(self.timer);
    }
}

- (void)suspend{
    dispatch_suspend(self.timer);
}

- (void)startScroll{
    [self scrollWith:true];
}

- (void)stopScroll{
    [self scrollWith:false];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSUInteger index = [self currentIndex];
    CGFloat w = CGRectGetWidth(self.bounds);
    if ([self.delegate respondsToSelector:@selector(scrollPanelView2:didScrollToIndex:fromIndex:progress:)]) {
        if (self.flag) {
            [self.delegate scrollPanelView2:self
                           didScrollToIndex:self.catheIndex
                                  fromIndex:self.selectIndex
                                   progress:1.0];
        }else{
            if (scrollView.contentOffset.x < w) {
                CGFloat progress = (w - scrollView.contentOffset.x)/CGRectGetWidth(scrollView.bounds);
                [self.delegate scrollPanelView2:self
                               didScrollToIndex:[self fetchWithCuttentIndex:self.selectIndex isUpOrDown:NO]
                                      fromIndex:self.selectIndex
                                       progress:progress];
            }else if (scrollView.contentOffset.x > w){
                CGFloat progress = (scrollView.contentOffset.x - w)/CGRectGetWidth(scrollView.bounds);
                [self.delegate scrollPanelView2:self
                               didScrollToIndex:[self fetchWithCuttentIndex:self.selectIndex isUpOrDown:YES]
                                      fromIndex:self.selectIndex
                                       progress:progress];
            }
        }
    }
    
    if (self.flag) {
        if (self.flagForNoAnimated) {
            self.flagForNoAnimated = NO;
            [self scrollViewDidEndScrollingAnimation:scrollView];
        }
        return;
    }
    if (index != 1) {
        return;
    }
    BOOL upOrDown = YES;
    UIView *containerView = nil;
    if (scrollView.contentOffset.x < w) {
        upOrDown = NO;
        containerView = self.firstView;
    }else if (scrollView.contentOffset.x > w){
        upOrDown = YES;
        containerView = self.lastView;
    }
    
    if (containerView) {
        [self containerView:containerView addSubviewAtIndex:[self fetchWithCuttentIndex:self.selectIndex isUpOrDown:upOrDown]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSUInteger index = [self currentIndex];
    if (self.flag) {
        self.flag = NO;
        self.selectIndex = self.catheIndex;
        if ([self.delegate respondsToSelector:@selector(scrollPanelView2:didCurrentIndexChange:)]) {
            [self.delegate scrollPanelView2:self didCurrentIndexChange:self.selectIndex];
        }
        self.pageControl.currentPage = self.selectIndex;
    }else{
        if (index == 1) {
            return;
        }
        
        if (index == 0) {
            self.selectIndex = [self fetchWithCuttentIndex:self.selectIndex isUpOrDown:NO];
            if ([self.delegate respondsToSelector:@selector(scrollPanelView2:didCurrentIndexChange:)]) {
                [self.delegate scrollPanelView2:self didCurrentIndexChange:self.selectIndex];
            }
            self.pageControl.currentPage = self.selectIndex;
        }else if(index == 2){
            self.selectIndex = [self fetchWithCuttentIndex:self.selectIndex isUpOrDown:YES];
            if ([self.delegate respondsToSelector:@selector(scrollPanelView2:didCurrentIndexChange:)]) {
                [self.delegate scrollPanelView2:self didCurrentIndexChange:self.selectIndex];
            }
            self.pageControl.currentPage = self.selectIndex;
        }
    }

    [self containerView:self.secondView addSubviewAtIndex:self.selectIndex];
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(scrollPanelView2WillBeginDragging:)]){
        [self.delegate scrollPanelView2WillBeginDragging:self];
    }
}

#pragma mark - private function

- (NSUInteger)fetchWithCuttentIndex:(NSUInteger)currentIndex isUpOrDown:(BOOL)upOrDown{
    NSInteger index = upOrDown ? currentIndex + 1 : currentIndex - 1;
    if (index >= [self vcCount]) {
        return 0;
    }else if (index < 0) {
        return MAX(0, [self vcCount]-1);
    }
    return index;
}

- (void)adjustScrollViewSubView{
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    self.firstView.frame = CGRectMake(w*0, 0, w, h);
    self.secondView.frame = CGRectMake(w*1, 0, w, h);
    self.lastView.frame = CGRectMake(w*2, 0, w, h);
}

- (UIView *)viewAtIndex:(NSUInteger)index{
    if (index >= [self vcCount]) {
        return nil;
    }
    if ([self.dataSource respondsToSelector:@selector(scrollPanelView2:viewAtIndex:)]) {
        return [self.dataSource scrollPanelView2:self viewAtIndex:index];
    }
    return nil;
}

- (NSInteger)vcCount{
    if ([self.dataSource respondsToSelector:@selector(numberOfViewsInScrollPanelView2:)]) {
        return [self.dataSource numberOfViewsInScrollPanelView2:self];
    }
    return 0;
}

- (NSUInteger)currentIndex{
    if (self.scrollView && CGRectGetWidth(self.scrollView.frame) > 0) {
        CGFloat w = CGRectGetWidth(self.scrollView.frame);
        CGFloat index = (self.scrollView.contentOffset.x + w*0.5) / w;
        return (NSInteger)index;
    }
    return self.selectIndex;
}

- (NSUInteger)selectIndex{
    if (_selectIndex >= [self vcCount]) {
        return MAX(0, [self vcCount]-1);
    }
    return MAX(0,_selectIndex);
}

#pragma mark - getter and setter

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = ({
            UIScrollView *tmp = [[UIScrollView alloc] init];
            tmp.pagingEnabled = YES;
            tmp.bounces = NO;
            tmp.showsVerticalScrollIndicator = NO;
            tmp.showsHorizontalScrollIndicator = NO;
            tmp;
        });
    }
    return _scrollView;
}

- (UIView *)firstView{
    if (!_firstView) {
        _firstView = ({
            UIView *tmp = [[UIView alloc] init];
            tmp.backgroundColor = [UIColor clearColor];
            _firstView = tmp;
            tmp;
        });
    }
    return _firstView;
}

- (UIView *)secondView{
    if (!_secondView) {
        _secondView = ({
            UIView *tmp = [[UIView alloc] init];
            tmp.backgroundColor = [UIColor clearColor];
            _secondView = tmp;
            tmp;
        });
    }
    return _secondView;
}

- (UIView *)lastView{
    if (!_lastView) {
        _lastView = ({
            UIView *tmp = [[UIView alloc] init];
            tmp.backgroundColor = [UIColor clearColor];
            _lastView = tmp;
            tmp;
        });
    }
    return _lastView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = ({
            UIPageControl *tmp = [[UIPageControl alloc] init];
            tmp.hidesForSinglePage = YES;
            tmp;
        });
    }
    return _pageControl;
}

- (void)setPageControlInsets:(UIEdgeInsets)pageControlInsets{
    if(UIEdgeInsetsEqualToEdgeInsets(pageControlInsets, _pageControlInsets)){
        return;
    }
    _pageControlInsets = pageControlInsets;
    [self setNeedsLayout];
}
@end
