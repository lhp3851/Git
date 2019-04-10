//
//  RyScrollPanelController.h
//  SleepDoctor
//
//  Created by aHao on 2017/5/4.
//  Copyright © 2017年 aHao. All rights reserved.
//
#import <UIKit/UIKit.h>

@class RyScrollPanelController;
@protocol RyScrollPanelControllerDataSource <NSObject>
@required
- (NSInteger)numberOfViewControllersInPanelViewController:(RyScrollPanelController *)panelViewController;

- (UIViewController *)panelViewController:(RyScrollPanelController *)panelViewController
                    viewControllerAtIndex:(NSInteger )index;
#if 0
@optional
- (UIBarButtonItem *)panelViewController:(RyScrollPanelController *)panelViewController
                leftBarButtonItemAtIndex:(NSInteger )index;

- (NSArray<UIBarButtonItem *> *)panelViewController:(RyScrollPanelController *)panelViewController
                         rightBarButtonItemsAtIndex:(NSInteger )index;
#endif
@end

@protocol RyScrollPanelControllerDelegate <NSObject>

@optional
- (void)panelViewController:(RyScrollPanelController *)panelViewController
        didScrollToProgress:(CGFloat)Progress;

- (void)panelViewController:(RyScrollPanelController *)panelViewController
      didCurrentIndexChange:(NSUInteger)currentIndex;

- (void)panelViewController:(RyScrollPanelController *)panelViewController
            didScrollToPage:(NSUInteger)toPage
                   fromPage:(NSUInteger)fromPage;
@end

///差一个reload，reload的功能后续再迭代
@interface RyScrollPanelController : UIViewController
@property (nonatomic, weak) id<RyScrollPanelControllerDataSource> dataSource;
@property (nonatomic, weak) id<RyScrollPanelControllerDelegate> delegate;
@property (nonatomic, assign, getter=isNeedAdjustPreferredStatusBarStyle) BOOL needAdjustPreferredStatusBarStyle;
//@property (nonatomic, strong, readonly) RyScrollPanelView *scrollPanelView;

- (void)selectViewControllerWithIndex:(NSInteger)index animated:(BOOL) animated;

@property(nonatomic,getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign, readonly) NSUInteger selectIndex;
- (CGFloat)currentProgress;
- (NSUInteger)currentIndex;
@end
