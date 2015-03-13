//
//  ViewController.m
//  XJTopWindow_Demo
//
//  Created by XJIMI on 2015/3/13.
//  Copyright (c) 2015年 XJIMI. All rights reserved.
//

#import "ViewController.h"
#import "XJTopWindow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [XJTopWindow initWithWindowLevel:UIWindowLevelNormal];
}

- (IBAction)show:(id)sender
{
    for (NSInteger i = 0; i < 10; i++) {
        NSString *title = [NSString stringWithFormat:@"%ld", (long)i];
        [XJTopWindow showWithViewController:[self createViewControllerWithTitle:title]];
    }
}

- (UIViewController *)createViewControllerWithTitle:(NSString *)title
{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor lightGrayColor];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:vc];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(dismissViewController)];
    vc.navigationItem.leftBarButtonItem = cancelButton;
    vc.title = title;
    return navc;
}

- (void)dismissViewController {
    [XJTopWindow dismiss];
}

@end
