//
//  RyScrollPanelView.m
//  SleepDoctor
//
//  Created by aHao on 2017/5/2.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import "RyScrollPanelView.h"
//////////////////////////////// PageProgress /////////////////////////////////////////////////
struct PageProgress {
    NSUInteger Index;
    CGFloat progress;
};
typedef struct PageProgress PageProgress;

static inline PageProgress PageProgressMake(NSUInteger Index, CGFloat progress)
{
    PageProgress p; p.Index = Index; p.progress = progress; return p;
}
///////////////////////////////////////////////////////////////////////////////////////////////

@interface RyScrollPanelView()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,UIView *> *viewDic;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *prepareSet;
@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL isSetWithNoAnimated;
@property (nonatomic, assign) PageProgress cathPageProgress;
@property (nonatomic, assign) NSUInteger catheIndex;
@end

@implementation RyScrollPanelView
- (instancetype)initWithFrame:(CGRect)frame defaultIndex:(NSUInteger)index{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSetWithNoAnimated = NO;
        self.isFirstLaunch = YES;
        _selectIndex = index;
        _catheIndex = -1;
        _cathPageProgress = PageProgressMake(-1, -1);
        [self setupSubview];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame defaultIndex:0];
}

- (void)setupSubview{
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    [self adjustScrollViewSubviews];
}

- (void)adjustScrollViewSubviews{
    BOOL flag = self.isFirstLaunch;
    if (flag) {
        self.isFirstLaunch = NO;
    }
    if (flag) {
        [self addViewAtIndex:self.selectIndex];
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat contentWidth = [self vcCount]*viewWidth;
    [self.viewDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        NSUInteger index = key.unsignedIntegerValue;
        UIView *todoView = obj;
        if (todoView.superview == self.scrollView) {
            CGRect todoRect = CGRectMake(index*viewWidth, 0, viewWidth, viewHeight);
            if ([self.dataSource respondsToSelector:@selector(scrollPanelView:viewFrameAtIndex:)]) {
                CGRect tmpRect = [self.dataSource scrollPanelView:self viewFrameAtIndex:index];
                todoRect = CGRectMake(CGRectGetMinX(todoRect) + CGRectGetMinX(tmpRect), CGRectGetMinY(todoRect) + CGRectGetMinY(tmpRect), CGRectGetWidth(tmpRect), CGRectGetHeight(tmpRect));
            }
            todoView.frame = todoRect;
        }else{
            NSLog(@"JIJI viewWillLayoutSubviews???? %lu",(unsigned long)index);
        }
    }];
    self.scrollView.contentSize = CGSizeMake(contentWidth, 0);
    
    if (flag) {
        [UIView animateWithDuration:0 animations:^{
            [self.scrollView setContentOffset:CGPointMake(self.selectIndex*viewWidth, 0)];
        } completion:^(BOOL finished) {
            self.scrollView.delegate = self;
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(scrollPanelViewWillBeginDragging:)]){
        [self.delegate scrollPanelViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSUInteger index = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    CGFloat current = fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame)) / CGRectGetWidth(scrollView.frame);
    if ([self.delegate respondsToSelector:@selector(scrollPanelView:didScrollToProgress:)]) {
        CGFloat progress = [self currentProgress];
        [self.delegate scrollPanelView:self didScrollToProgress:progress];
    }
    
    if (self.cathPageProgress.Index != index) {
        [self addViewAtIndex:index];

    }else if(self.cathPageProgress.progress < current){
        [self addViewAtIndex:index+1];
    }
    
    NSUInteger delegateIndex = [self currentIndex];
    if (self.catheIndex != delegateIndex) {
        self.catheIndex = delegateIndex;
        if ([self.delegate respondsToSelector:@selector(scrollPanelView:didCurrentIndexChange:)]) {
            [self.delegate scrollPanelView:self didCurrentIndexChange:delegateIndex];
        }
    }
    self.cathPageProgress = PageProgressMake(index, current);
    if (_isSetWithNoAnimated) {
        _isSetWithNoAnimated = NO;
        [self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSUInteger index = [self currentIndex];
    CGFloat fromPage = self.selectIndex;
    if (index != self.selectIndex) {
        self.selectIndex = index;
    }
    if ([self.delegate respondsToSelector:@selector(scrollPanelView:didScrollToPage:fromPage:)]) {
        [self.delegate scrollPanelView:self didScrollToPage:index fromPage:fromPage];
    }
}

#pragma mark - private function
- (BOOL)canSelectIndex:(NSUInteger)index{
    if (self.selectIndex == index) {
        return NO;
    }
    if (index >= [self vcCount]) {
        return NO;
    }
    if (self.isFirstLaunch) {
        self.selectIndex = index;
        return NO;
    }
    return YES;
}
- (void)setSelectViewWithIndex:(NSInteger)index animated:(BOOL) animated{
    if (![self canSelectIndex:index]) {
        return;
    }
    [self addViewAtIndex:index];
    self.isSetWithNoAnimated = !animated;
    [self.scrollView setContentOffset:CGPointMake(index*CGRectGetWidth(self.scrollView.frame), 0) animated:animated];
}

- (void)addViewAtIndex:(NSUInteger)index{
    if (index >= [self vcCount]) {
        return;
    }
    
    NSMutableArray *todoIndexs = [NSMutableArray arrayWithCapacity:3];
    [todoIndexs addObject:@(index)];
    if ( index >= 1 ) {
        [todoIndexs addObject:@(index-1)];
    }
    
    if (index + 1 < [self vcCount]) {
        [todoIndexs addObject:@(index + 1)];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollPanelView:prepareForViewAtIndex:)]) {
        for (NSNumber *todoNum in todoIndexs) {
            if (![self.prepareSet containsObject:todoNum]){
                [self.prepareSet addObject:todoNum];
                [self.delegate scrollPanelView:self prepareForViewAtIndex:todoNum.unsignedIntegerValue];
            }
        }
    }

    
    UIView *todoView = self.viewDic[[NSNumber numberWithUnsignedInteger:index]];//[self viewAtIndex:index];
    if (!todoView) {
        todoView = [self viewAtIndex:index];
    }
    if (todoView && (!todoView.superview || todoView.superview != self.scrollView)) {
        if ([self.delegate respondsToSelector:@selector(scrollPanelView:willAddSubViewAtIndex:)]) {
            [self.delegate scrollPanelView:self willAddSubViewAtIndex:index];
        }
        [self.scrollView addSubview:todoView];
        self.viewDic[[NSNumber numberWithUnsignedInteger:index]] = todoView;
        [self adjustScrollViewSubviews];
        if ([self.delegate respondsToSelector:@selector(scrollPanelView:didAddSubViewAtIndex:)]) {
            [self.delegate scrollPanelView:self didAddSubViewAtIndex:index];
        }
    }
}

- (PageProgress)pageProgressFromProgress:(CGFloat)progress{
    CGFloat total = MAX(0, self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame));
    CGFloat offsetX = progress * total;
    NSUInteger index = offsetX / CGRectGetWidth(self.scrollView.frame);
    CGFloat current = fmod(offsetX, CGRectGetWidth(self.scrollView.frame)) / CGRectGetWidth(self.scrollView.frame);
    return PageProgressMake(index, current);
}

#pragma mark - setter and getter
- (UIView *)viewAtIndex:(NSUInteger)index{
    if ([self.dataSource respondsToSelector:@selector(scrollPanelView:viewAtIndex:)]) {
        return [self.dataSource scrollPanelView:self viewAtIndex:index];
    }
    return nil;
}

- (NSInteger)vcCount{
    if ([self.dataSource respondsToSelector:@selector(numberOfViewsInScrollPanelView:)]) {
        return [self.dataSource numberOfViewsInScrollPanelView:self];
    }
    return 0;
}

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

- (NSUInteger)selectIndex{
    if (_selectIndex >= [self vcCount]) {
        return MAX(0, [self vcCount]-1);
    }
    return _selectIndex;
}

- (CGFloat)currentProgress{
    if (self.isFirstLaunch) {
        if ([self vcCount] == 1) {
            return 0;
        }
        if ([self vcCount] > 1) {
            return self.selectIndex/(CGFloat)([self vcCount] - 1);
        }
        return 0;
    }
    CGFloat total = MAX(0, self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame));
    CGFloat progress = 0;
    if (total != 0) {
        progress = self.scrollView.contentOffset.x/total;
    }
    return progress;
}

- (NSUInteger)currentIndex{
    if (self.scrollView && CGRectGetWidth(self.scrollView.frame) > 0) {
        CGFloat index = (self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame)*0.5) / CGRectGetWidth(self.scrollView.frame);
        return (NSInteger)index;
    }
    return self.selectIndex;
}

- (NSMutableDictionary<NSNumber *,UIView *> *)viewDic{
    if (!_viewDic) {
        _viewDic = [NSMutableDictionary dictionary];
    }
    return _viewDic;
}

- (NSMutableSet<NSNumber *> *)prepareSet{
    if (!_prepareSet) {
        _prepareSet = [NSMutableSet set];
    }
    return _prepareSet;
}

- (NSDictionary<NSNumber *,UIView *> *)dataSourceViewDictionary{
    return _viewDic;
}

@end
