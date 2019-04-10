//
//  RyScrollPanelView.h
//  SleepDoctor
//
//  Created by aHao on 2017/5/2.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RyScrollPanelView;
@protocol RyScrollPanelViewDataSource <NSObject>

@required
- (NSUInteger)numberOfViewsInScrollPanelView:(RyScrollPanelView *)scrollPanelView;
- (UIView *)scrollPanelView:(RyScrollPanelView *)scrollPanelView
                viewAtIndex:(NSUInteger)index;
@optional
- (CGRect)scrollPanelView:(RyScrollPanelView *)scrollPanelView
         viewFrameAtIndex:(NSUInteger)index;

@end

@protocol RyScrollPanelViewDelegate <NSObject>

@optional
- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
    didScrollToProgress:(CGFloat)Progress;

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
  didCurrentIndexChange:(NSUInteger)currentIndex;

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
        didScrollToPage:(NSUInteger)toPage
               fromPage:(NSUInteger)fromPage;
- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
  prepareForViewAtIndex:(NSUInteger)index;

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
   willAddSubViewAtIndex:(NSUInteger)index;

- (void)scrollPanelView:(RyScrollPanelView *)scrollPanelView
   didAddSubViewAtIndex:(NSUInteger)index;

- (void)scrollPanelViewWillBeginDragging:(RyScrollPanelView *)scrollPanelView;
@end

@interface RyScrollPanelView : UIView
@property (nonatomic, weak) id<RyScrollPanelViewDataSource> dataSource;
@property (nonatomic, weak) id<RyScrollPanelViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger selectIndex;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
- (instancetype)initWithFrame:(CGRect)frame defaultIndex:(NSUInteger)index;
- (BOOL)canSelectIndex:(NSUInteger)index;
- (void)setSelectViewWithIndex:(NSInteger)index animated:(BOOL) animated;
- (CGFloat)currentProgress;
- (NSUInteger)currentIndex;
- (NSDictionary<NSNumber *,UIView *> *)dataSourceViewDictionary;

@end
