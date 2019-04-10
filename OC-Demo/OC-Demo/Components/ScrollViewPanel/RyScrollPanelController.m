//
//  RyScrollPanelController.m
//  SleepDoctor
//
//  Created by aHao on 2017/5/4.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import "RyScrollPanelController.h"
#import "RyScrollPanelView.h"


@interface RyScrollPanelController ()<RyScrollPanelViewDataSource,RyScrollPanelViewDelegate>
@property (nonatomic, strong) NSMutableArray <UIViewController *> *vcArray;
@property (nonatomic, strong) RyScrollPanelView *scrollPanelView;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) BOOL forwardAppearanceMethods;
@property (nonatomic, assign) NSUInteger catheIndex;
@end

@implementation RyScrollPanelController

- (instancetype)init{
    self = [super init];
    if (self) {
        _isFirst = YES;
        _isChange = NO;
        _scrollEnabled = YES;
        _forwardAppearanceMethods = NO;
        _needAdjustPreferredStatusBarStyle = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollPanelView];
    self.vcArray = [NSMutableArray array];
    for (int i = 0; i < [self vcCount]; i ++) {
        UIViewController *todoVC = [self vcAtIndex:i];
        NSAssert(todoVC, @"不能返回nil的VC");
        [self.vcArray addObject:todoVC];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_forwardAppearanceMethods) {
        [self.vcArray[self.scrollPanelView.selectIndex] beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_forwardAppearanceMethods) {
        [self.vcArray[self.scrollPanelView.selectIndex] endAppearanceTransition];
    }
    _forwardAppearanceMethods = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_forwardAppearanceMethods) {
        [self.vcArray[self.scrollPanelView.selectIndex] beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_forwardAppearanceMethods) {
        [self.vcArray[self.scrollPanelView.selectIndex] endAppearanceTransition];
    }
}

- (void)handleSelectedVCApperance:(BOOL)animated{

}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollPanelView.frame = self.view.bounds;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    NSUInteger index = [self.scrollPanelView currentIndex];
    if (self.vcArray.count > index) {
        return self.vcArray[index].preferredStatusBarStyle;
    }
    return UIStatusBarStyleLightContent;
}

#pragma mark - public function
- (NSUInteger)selectIndex{
    return self.scrollPanelView.selectIndex;
}

- (NSUInteger)currentIndex{
    return [self.scrollPanelView currentIndex];
}

- (CGFloat)currentProgress{
    return [self.scrollPanelView currentProgress];
}

- (void)selectViewControllerWithIndex:(NSInteger)index animated:(BOOL) animated{
    BOOL flag = [self.scrollPanelView canSelectIndex:index];
    if (flag) {
        

        UIViewController *todoVC = self.vcArray[[self.scrollPanelView currentIndex]];
        [todoVC beginAppearanceTransition:NO animated:YES];
        self.isChange = YES;
        [self.scrollPanelView setSelectViewWithIndex:index animated:animated];
    }
}

#pragma mark - private function
- (UIViewController *)vcAtIndex:(NSUInteger)index{
    if ([self.dataSource respondsToSelector:@selector(panelViewController:viewControllerAtIndex:)]) {
        return [self.dataSource panelViewController:self viewControllerAtIndex:index];
    }
    return nil;
}

- (NSInteger)vcCount{
    if ([self.dataSource respondsToSelector:@selector(numberOfViewControllersInPanelViewController:)]) {
        return [self.dataSource numberOfViewControllersInPanelViewController:self];
    }
    return 0;
}

#pragma mark - getter and setter
- (RyScrollPanelView *)scrollPanelView{
    if (!_scrollPanelView) {
        _scrollPanelView = [[RyScrollPanelView alloc] initWithFrame:CGRectZero defaultIndex:0];
        _scrollPanelView.dataSource = self;
        _scrollPanelView.delegate = self;
    }
    return _scrollPanelView;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    _scrollEnabled = scrollEnabled;
    self.scrollPanelView.scrollView.scrollEnabled = _scrollEnabled;
}
#pragma mark - RyScrollPanelViewDataSource
- (NSUInteger)numberOfViewsInScrollPanelView:(RyScrollPanelView *)scrollPanelView{
    return self.vcArray.count;
}

- (UIView *)scrollPanelView:(RyScrollPanelView *)scrollPanelView
                viewAtIndex:(NSUInteger)index{
    return self.vcArray[index].view;
}

#pragma mark - RyScrollPanelViewDelegate
- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView willAddSubViewAtIndex:(NSUInteger)index{
    UIViewController *todoVC = self.vcArray[index];
    [self addChildViewController:todoVC];
    if (self.isFirst) {
        [todoVC beginAppearanceTransition:YES animated:YES];
    }
}

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView didAddSubViewAtIndex:(NSUInteger)index{
    UIViewController *todoVC = self.vcArray[index];
    [todoVC didMoveToParentViewController:self];
    if (self.isFirst){
        [todoVC endAppearanceTransition];
        self.isFirst = NO;
    }
}

- (void)scrollPanelViewWillBeginDragging:(RyScrollPanelView *)scrollPanelView{
    self.catheIndex = [scrollPanelView currentIndex];
}

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
    didScrollToProgress:(CGFloat)Progress{
//    NSLog(@"JIJIJIJI didScrollToProgress ViewController7 Progress : %f",Progress);
    if ([self.delegate respondsToSelector:@selector(panelViewController:didScrollToProgress:)]) {
        [self.delegate panelViewController:self didScrollToProgress:Progress];
    }
    
    if (Progress == 0 || Progress == 1) {
        return;
    }
    if (self.isFirst) {
        return;
    }
    
    if (self.scrollPanelView.scrollView.isDragging && !self.isChange && self.catheIndex != [scrollPanelView currentIndex]) {
        self.isChange = YES;

        UIViewController *todoVC = self.vcArray[self.catheIndex];
        [todoVC beginAppearanceTransition:NO animated:YES];

    }
}

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView didCurrentIndexChange:(NSUInteger)currentIndex{
    NSLog(@"JIJIJIJI didCurrentIndexChange ViewController7 currentIndex : %ld",currentIndex);

//    UIViewController *todoAdd = self.vcArray[currentIndex];
//
//    if (self.isNeedAdjustPreferredStatusBarStyle) {
//        [[UIApplication sharedApplication] setStatusBarStyle:todoAdd.preferredStatusBarStyle animated:YES];
//    }
    if ([self.delegate respondsToSelector:@selector(panelViewController:didCurrentIndexChange:)]) {
        [self.delegate panelViewController:self didCurrentIndexChange:currentIndex];
    }
}

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView didScrollToPage:(NSUInteger)toPage fromPage:(NSUInteger)fromPage{
    NSLog(@"JIJIJIJI didScrollToPage ViewController7 fromPage: %ld -> toPage: %ld",fromPage,toPage);
    if (!self.isChange) {
        return;
    }
    self.isChange = NO;
    if (toPage == fromPage) {
        UIViewController *todoVC = self.vcArray[toPage];
        [todoVC beginAppearanceTransition:YES animated:YES];
        [todoVC endAppearanceTransition];
    }else{
        UIViewController *todoAdd = self.vcArray[toPage];
        UIViewController *todoRemove = self.vcArray[fromPage];
        [todoAdd beginAppearanceTransition:YES animated:YES];
        [todoRemove endAppearanceTransition];
        [todoAdd endAppearanceTransition];
    }
    if ([self.delegate respondsToSelector:@selector(panelViewController:didScrollToPage:fromPage:)]) {
        [self.delegate panelViewController:self didScrollToPage:toPage fromPage:fromPage];
    }
}

@end
