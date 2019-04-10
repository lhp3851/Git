//
//  RyScrollPanelColorHelper.h
//  SleepDoctor
//
//  Created by aHao on 2017/5/10.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RyScrollPanelColorHelper : NSObject
@property (nonatomic, readonly) NSArray<UIColor *> *colors;

- (instancetype)initWithColors:(NSArray<UIColor *> *)colors;
- (UIColor *)colorFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress;

///
+ (UIColor *)fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;
@end
