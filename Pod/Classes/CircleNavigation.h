//
//  CircleNavigation.h
//  CircleNavigation
//
//  Created by guoshencheng on 11/23/15.
//  Copyright © 2015 guoshencheng. All rights reserved.
//

#import "CircleNavigationItem.h"

@protocol CircleNavigationDelegate;
@protocol CircleNavigationDatasource;

@interface NavigationItemModule : NSObject

@property (strong, nonatomic) NSString *iconImageName;
@property (strong, nonatomic) NSString *iconClickedImageName;
@property (strong, nonatomic) NSString *text;

@end

@interface CircleNavigationConfig : NSObject

@property (assign, nonatomic) CGSize itemSize;
@property (assign, nonatomic) CGSize iconSize;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat bottom;

+ (instancetype)sharedConfig;

@end

@interface CircleNavigation : UIView<CircleNavigationItemDelegate>

@property (weak, nonatomic) id<CircleNavigationDatasource> datasource;
@property (weak, nonatomic) id<CircleNavigationDelegate> delegate;

@property (assign, nonatomic) CGFloat transitionProgress;

+ (instancetype)sharedCircleNavigation;
+ (instancetype)create;
- (void)showWithAnimation:(BOOL)animation;
- (void)hideWithAnimation:(BOOL)animation;
- (void)resetItems;
- (void)reset;
- (void)registItemModule:(NavigationItemModule *)module forKey:(NSString *)key;
- (NavigationItemModule *)dequeueModuleWithKey:(NSString *)key;
- (void)resetItemImage:(UIImage *)image clickedImage:(UIImage *)clickedImage title:(NSString *)title atIndex:(NSInteger)index;

@end

@protocol CircleNavigationDelegate <NSObject>
@optional
- (void)circleNavigation:(CircleNavigation *)circleNavigation didClickItemAtIndex:(NSInteger)index;

@end

@protocol CircleNavigationDatasource <NSObject>
@required
- (NSInteger)numberOfItemsInCircleNavigation:(CircleNavigation *)circleNavigation;
- (NSString *)circleNavigation:(CircleNavigation *)circleNavigation itemKeyAtIndex:(NSInteger)index;
- (NSString *)circleNavigationIconImage:(CircleNavigation *)circle atProgress:(CGFloat)progress;
- (NSString *)circleNavigationIconClickedImage:(CircleNavigation *)circle atProgress:(CGFloat)progress;

@end