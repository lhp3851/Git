//
//  ViewController.m
//  OC-Demo
//
//  Created by sumian on 2019/1/18.
//  Copyright © 2019 lhp3851. All rights reserved.
//

#import "ViewController.h"
#import "Components/ScrollViewPanel/RyScrollPanelView2.h"

@interface ViewController ()<RyScrollPanelView2Delegate,RyScrollPanelView2DataSource>{
    NSInteger imageCounts;
}

@property(nonatomic,strong)NSArray<UIImageView *> * imageViewes;
@property(nonatomic,strong)NSArray<NSString *> * images;
@property(nonatomic,strong)RyScrollPanelView2 *scollView;

@end

@implementation ViewController

-(NSArray<NSString *> *)images{
    if (!_images) {
        _images = [[NSArray alloc]initWithObjects:@"2018-11-07.png",@"2018-11-08.png", @"2018-11-09.png",nil];
    }
    return _images;
}

-(NSArray<UIImageView *> *)imageViewes{
    if (!_imageViewes) {
        NSMutableArray *imageViewes = [NSMutableArray array];
        for (int i = 0 ; i < imageCounts; i++) {
            UIImageView *view = [[UIImageView alloc] init];
            view.image = [UIImage imageNamed:self.images[i]];
            [imageViewes addObject:view];
        }
        _imageViewes = imageViewes;
    }
    return _imageViewes;
}

-(RyScrollPanelView2 *)scollView{
    if (!_scollView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGRect frame = CGRectMake(0 , 64, width, 250);
        _scollView = [[RyScrollPanelView2 alloc]initWithFrame:frame defaultIndex:0];
        _scollView.backgroundColor = [UIColor blueColor];
        _scollView.delegate = self;
        _scollView.dataSource = self;
    }
    return _scollView;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeNoti];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self setUpView];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.scollView stopScroll];
//    });
    [self addNoti];
}

- (void)initDatas{
    imageCounts = 3;
}

- (void)setUpView{
    [self.view addSubview:self.scollView];
}

- (void)suspend{
    [self.scollView suspend];
}

- (void)resume{
    [self.scollView startScroll];
}

- (void)addNoti{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resume) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(suspend) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeNoti{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark RyScrollPanelView2Delegate 代理
- (void)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2
        didScrollToIndex:(NSUInteger)toIndex
               fromIndex:(NSUInteger)fromIndex
                progress:(CGFloat)progress{
//    NSLog(@"scroll:%@,from:%lu,to:%lu,progress:%f",scrollPanelView2,fromIndex,toIndex,progress);
}

- (void)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2 didCurrentIndexChange:(NSUInteger)currentIndex{
    NSLog(@"scroll:%@,index:%lu",scrollPanelView2,(unsigned long)currentIndex);
}

- (void)scrollPanelView2WillBeginDragging:(RyScrollPanelView2 *)scrollPanelView2{
    NSLog(@"scroll:%@",scrollPanelView2);
}

#pragma mark RyScrollPanelView2DataSource 代理
- (NSUInteger)numberOfViewsInScrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2{
    return self.images.count;
}

- (UIView *)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2 viewAtIndex:(NSUInteger)index{
    return self.imageViewes[index];
}

- (CGRect)scrollPanelView2:(RyScrollPanelView2 *)scrollPanelView2 viewFrameAtIndex:(NSUInteger)index{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect frame = CGRectMake(0 , 0, width, 250);
    return  frame;
}
@end
