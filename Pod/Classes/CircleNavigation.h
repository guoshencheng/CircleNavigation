//
//  CircleNavigation.h
//  CircleNavigation
//
//  Created by guoshencheng on 11/23/15.
//  Copyright © 2015 guoshencheng. All rights reserved.
//

#import "CircleNavigationItem.h"

typedef void (^Block)(BOOL success);
@interface UIImageView (CircleNavigation)

-(void)startAnimatingWithCompletionBlock:(Block)block;

@end

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

+ (instancetype)sharedCircleNavigation;
+ (instancetype)create;

- (void)reset;
- (void)resetItems;
- (void)showWithAnimation:(BOOL)animation;
- (void)hideWithAnimation:(BOOL)animation;
- (void)playAnimationForKey:(NSString *)key expand:(BOOL)expand;
- (void)swichMainButtonImage:(UIImage *)image;
- (void)registSprites:(NSArray *)sprites forKey:(NSString *)key;
- (void)registItemModule:(NavigationItemModule *)module forKey:(NSString *)key;
- (void)resetItemImage:(UIImage *)image clickedImage:(UIImage *)clickedImage title:(NSString *)title atIndex:(NSInteger)index;
- (NavigationItemModule *)dequeueModuleWithKey:(NSString *)key;

@end

@protocol CircleNavigationDelegate <NSObject>
@optional
- (void)circleNavigation:(CircleNavigation *)circleNavigation didClickItemAtIndex:(NSInteger)index;

@end

@protocol CircleNavigationDatasource <NSObject>
@required
- (NSInteger)numberOfItemsInCircleNavigation:(CircleNavigation *)circleNavigation;
- (NSString *)circleNavigation:(CircleNavigation *)circleNavigation itemKeyAtIndex:(NSInteger)index;
- (NSString *)circleNavigationIconImage:(CircleNavigation *)circle;
- (NSString *)circleNavigationIconClickedImage:(CircleNavigation *)circle;

@end