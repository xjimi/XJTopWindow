//
//  XJTopWindow.m
//  Waker
//
//  Created by XJIMI on 2015/3/11.
//  Copyright (c) 2015年 jimi. All rights reserved.
//

#import "XJTopWindow.h"

#define XJTOPWINDOW [XJTopWindow sharedObject]

const UIWindowLevel XJTopWindowLevel = 1998.0; //UIWindowLevelAlert is 2000

@interface XJTopWindow ()

@property (nonatomic, strong) UIWindow *originalWindow;
@property (nonatomic, assign) UIWindowLevel windowLevel;
@property (nonatomic, strong) UIWindow *topWindow;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) BOOL isShowing;

@end

@implementation XJTopWindow

#pragma mark - public method

+ (void)initWithWindowLevel:(UIWindowLevel)windowLevel {
    XJTOPWINDOW.windowLevel = windowLevel;
}

+ (void)showWithViewController:(UIViewController *)viewController
{
    [XJTOPWINDOW.viewControllers addObject:viewController];
    [XJTOPWINDOW show];
}

+ (void)dismiss {
    [XJTOPWINDOW show];
}

#pragma mark - private method

- (void)show
{
    if (self.isShowing) return;
    self.isShowing = YES;
    __weak typeof(self)weakSelf = self;
    [self dismissWithCompletion:^{
        if (weakSelf.viewControllers.count) {
            UIViewController *vc = weakSelf.viewControllers[0];
            weakSelf.viewController = vc;
            [weakSelf.viewControllers removeObject:vc];
            [weakSelf showViewControllerWithCompletion:^{
                weakSelf.isShowing = NO;
                if (weakSelf.viewControllers.count) [weakSelf show];
            }];
        } else {
            weakSelf.isShowing = NO;
        }
    }];
}

- (void)showViewControllerWithCompletion:(void (^)(void))completion
{
    if (!self.topWindow) {
        __weak typeof(self)weakSelf = self;
        self.topWindow = [self createWindowWithWindowLevel:self.windowLevel];
        [self.topWindow makeKeyAndVisible];
        [XJTopWindow delaySecond:.3 completion:^{
            [weakSelf presentViewControllerWithCompletion:completion];
        }];
    } else {
        [self presentViewControllerWithCompletion:completion];
    }
}

- (void)presentViewControllerWithCompletion:(void (^)(void))completion {
    [self.topWindow.rootViewController presentViewController:self.viewController animated:YES completion:^{
        [XJTopWindow delaySecond:.3 completion:completion];
    }];
}

- (void)dismissWithCompletion:(void (^)(void))compltion
{
    if (self.topWindow)
    {
        __weak typeof(self)weakSelf = self;
        [self.topWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
            weakSelf.viewController = nil;
            if (!weakSelf.viewControllers.count) {
                weakSelf.topWindow.hidden = YES;
                weakSelf.topWindow = nil;
                weakSelf.originalWindow.hidden = NO;
                [weakSelf.originalWindow makeKeyAndVisible];
            }
            if (compltion) compltion();
        }];
    } else {
        if (compltion) compltion();
    }
}

- (UIWindow *)createWindowWithWindowLevel:(UIWindowLevel)windowLevel
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.opaque = YES;
    window.windowLevel = windowLevel ? : UIWindowLevelNormal;
    window.rootViewController = [UIViewController new];
    return window;
}

+ (instancetype)sharedObject
{
    static XJTopWindow *sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[XJTopWindow alloc] init];
        sharedView.originalWindow = [UIApplication sharedApplication].keyWindow;
        sharedView.viewControllers = [[NSMutableArray alloc] init];
    });
    return sharedView;
}

#pragma mark - tool

+ (void)delaySecond:(double)delay completion:(void(^)(void))completion
{
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (completion) completion();
    });
}

@end
