//
//  RyScrollPanelView2.h
//  SleepDoctor
//
//  Created by aHao on 2017/5/9.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RyScrollPanelView2;
@protocol RyScrollPanelView2DataSource <NSObject>

@required
- (NSUInteger)numberOfViewsInScrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2;
- (UIView *)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2
                 viewAtIndex:(NSUInteger)index;
@optional
- (CGRect)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2
          viewFrameAtIndex:(NSUInteger)index;

@end

@protocol RyScrollPanelView2Delegate <NSObject>

@optional
- (void)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2
        didScrollToIndex:(NSUInteger)toIndex
               fromIndex:(NSUInteger)fromIndex
                progress:(CGFloat)progress;

- (void)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2
   didCurrentIndexChange:(NSUInteger)currentIndex;

- (void)scrollPanelView2WillBeginDragging:(RyScrollPanelView2 *)scrollPanelView2;
@end

///带pageControl,三页面循环
@interface RyScrollPanelView2 : UIView<UIScrollViewDelegate>
@property (nonatomic, weak) id<RyScrollPanelView2DataSource> dataSource;
@property (nonatomic, weak) id<RyScrollPanelView2Delegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger selectIndex;
@property (nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic, assign) UIEdgeInsets pageControlInsets;
- (instancetype)initWithFrame:(CGRect)frame defaultIndex:(NSUInteger)defaultIndex;
- (void)displayViewAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadData;

- (void)startScroll;
- (void)suspend;
- (void)stopScroll;

- (CGFloat)normalizationProgressWithToIndex:(NSUInteger)toIndex
                               fromIndex:(NSUInteger)fromIndex
                                progress:(CGFloat)progress;
@end
