//
//  CircleNavigationItem.h
//  CircleNavigation
//
//  Created by guoshencheng on 11/23/15.
//  Copyright © 2015 guoshencheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Masonry;
@class POP;

@protocol CircleNavigationItemDelegate;

typedef void(^PackUpAnimationCompletion)(NSInteger index);

@interface CircleNavigationItem : UIView

@property (weak, nonatomic) id<CircleNavigationItemDelegate>delegate;
@property (assign, nonatomic) CGPoint targetPostion;
@property (assign, nonatomic) CGPoint originPostion;
@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) PackUpAnimationCompletion packUpAnimationCompletion;

+ (instancetype)create;
- (void)setupWithImage:(UIImage *)image highLightImage:(UIImage *)highLightImage title:(NSString *)title;
- (void)updateWithImage:(UIImage *)image highLightImage:(UIImage *)highLightImage title:(NSString *)title;
- (void)animateToTargetPostion;
- (void)animateToOriginPostion;

@end

@protocol CircleNavigationItemDelegate <NSObject>
@optional
- (void)circleNavigationItemDidClicked:(CircleNavigationItem *)circleNavigationItem;

@end
