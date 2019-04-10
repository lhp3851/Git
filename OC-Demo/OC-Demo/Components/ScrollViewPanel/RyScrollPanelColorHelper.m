//
//  RyScrollPanelColorHelper.m
//  SleepDoctor
//
//  Created by aHao on 2017/5/10.
//  Copyright © 2017年 aHao. All rights reserved.
//

#import "RyScrollPanelColorHelper.h"
@interface RyScrollPanelColorHelper()
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@end

@implementation RyScrollPanelColorHelper
- (instancetype)initWithColors:(NSArray<UIColor *> *)colors{
    self = [super init];
    if (self) {
        if (!colors || colors.count < 2) {
            return nil;
        }
        _colors = colors;
    }
    return self;
}

- (UIColor *)colorFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress{
    UIColor *toColor = self.colors[toIndex];
    UIColor *fromColor = self.colors[fromIndex];
    return [RyScrollPanelColorHelper fromColor:fromColor toColor:toColor progress:progress];
}

+ (UIColor *)fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress{
    CGFloat fR,fG,fB;
    CGFloat tR,tG,tB;
    [fromColor getRed:&fR green:&fG blue:&fB alpha:nil];
    [toColor getRed:&tR green:&tG blue:&tB alpha:nil];
    UIColor *color = [UIColor colorWithRed:(tR - fR) * progress + fR
                                     green:(tG - fG) * progress + fG
                                      blue:(tB - fB) * progress + fB
                                     alpha:1];
    return color;
}
@end
