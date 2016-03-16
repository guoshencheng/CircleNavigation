//
//  CGAppDelegate.m
//  CircleNavigation
//
//  Created by guoshencheng on 03/14/2016.
//  Copyright (c) 2016 guoshencheng. All rights reserved.
//

#import "CGAppDelegate.h"
#import "CGViewController.h"
#import <CircleNavigation.h>

@interface CGAppDelegate () <CircleNavigationDatasource, CircleNavigationDelegate>

@end

@implementation CGAppDelegate {
    UINavigationController *navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CGViewController *viewController = [CGViewController create];
    navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    CircleNavigation *circleNavigation = [CircleNavigation sharedCircleNavigation];
    circleNavigation.delegate = self;
    circleNavigation.datasource = self;
    [self.window addSubview:circleNavigation];
    [circleNavigation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    NavigationItemModule *module = [NavigationItemModule new];
    module.iconImageName = @"test_image";
    module.iconClickedImageName = @"test_image";
    module.text = @"description";
    [circleNavigation registItemModule:module forKey:@"item"];
    [circleNavigation resetItems];
    [self.window makeKeyAndVisible];
    [self.window bringSubviewToFront:circleNavigation];
    return YES;
}

- (NSString *)circleNavigationIconImage:(CircleNavigation *)circle atProgress:(CGFloat)progress {
    return @"test_image";
}

- (NSInteger)numberOfItemsInCircleNavigation:(CircleNavigation *)circleNavigation {
    return 4;
}

- (NSString *)circleNavigation:(CircleNavigation *)circleNavigation itemKeyAtIndex:(NSInteger)index {
    return @"item";
}

- (void)circleNavigation:(CircleNavigation *)circleNavigation didClickItemAtIndex:(NSInteger)index {
    NSLog(@"%@", @(index));
    [navigationController pushViewController:[CGViewController create] animated:YES];
}

@end
