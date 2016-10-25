//
//  CircleNavigation.m
//  CircleNavigation
//
//  Created by guoshencheng on 11/23/15.
//  Copyright © 2015 guoshencheng. All rights reserved.
//

#import "Masonry.h"
#import "POP.h"
#import "CircleNavigation.h"
#import <objc/runtime.h>

#define BLOCK_KEY @"BLOCK_KEY"
#define CONTENTS  @"contents"
@implementation UIImageView (CircleNavigation)

- (void)setblock:(Block)block {
    objc_setAssociatedObject(self, (__bridge const void *)(BLOCK_KEY), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Block)block {
    return objc_getAssociatedObject(self, (__bridge const void *)(BLOCK_KEY));
}

- (void)startAnimatingWithCompletionBlock:(Block)block {
    [self startAnimatingWithCGImages:getCGImagesArray(self.animationImages) CompletionBlock:block];
}

- (void)startAnimatingWithCGImages:(NSArray*)cgImages CompletionBlock:(Block)block {
    [self setblock:block];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    [anim setKeyPath:CONTENTS];
    [anim setValues:cgImages];
    [anim setRepeatCount:self.animationRepeatCount];
    [anim setDuration:self.animationDuration];
    anim.delegate = self;

    CALayer *ImageLayer = self.layer;
    [ImageLayer addAnimation:anim forKey:nil];
}

NSArray *getCGImagesArray(NSArray* UIImagesArray) {
    NSMutableArray* cgImages;
    @autoreleasepool {
        cgImages = [[NSMutableArray alloc] init];
        for (UIImage* image in UIImagesArray)
            [cgImages addObject:(id)image.CGImage];
    }
    return cgImages;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    Block block_ = [self block];
    if (block_)block_(flag);
}
@end

@implementation NavigationItemModule

@end

@implementation CircleNavigationConfig

+ (instancetype)sharedConfig {
    static CircleNavigationConfig *circleNavigationConfig = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        circleNavigationConfig = [[CircleNavigationConfig alloc] init];
        [circleNavigationConfig makeDefultConfig];
    });
    return circleNavigationConfig;
}

- (void)makeDefultConfig {
    CGFloat length = [UIScreen mainScreen].bounds.size.width;
    self.iconSize = CGSizeMake(length * 0.17, length * 0.17);
    self.itemSize = CGSizeMake(51, 51);
    self.radius = length * 0.6;
    self.left = 20;
    self.bottom = 20;
}

@end

@interface CircleNavigation ()

@property (strong, nonatomic) UIButton *mainButton;
@property (strong, nonatomic) UIButton *backgroundButton;

@property (strong, nonatomic) NSMutableDictionary *itemModuleCache;
@property (strong, nonatomic) NSMutableDictionary *spritesCache;
@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) BOOL isPackUp;

@end

@implementation CircleNavigation

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UIButton class]]) {
        return view;
    }
    return nil;
}

#pragma mark - PublicMethod

+ (instancetype)sharedCircleNavigation {
    static CircleNavigation *circleNavigation = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        circleNavigation = [CircleNavigation create];
    });
    return circleNavigation;
}

+ (instancetype)create {
    CircleNavigation *circleNavigation = [[CircleNavigation alloc] init];
    circleNavigation.translatesAutoresizingMaskIntoConstraints = NO;
    [circleNavigation setup];
    return circleNavigation;
}

- (void)reset {
    [self configureMainButton];
    [self configureBackgroundButton];
    self.isPackUp = YES;
}

- (void)resetItems {
    [self clear];
    [self reset];
    [self generateAllItems];
}

- (void)showWithAnimation:(BOOL)animation {
    self.hidden = NO;
}

- (void)hideWithAnimation:(BOOL)animation {
    self.hidden = YES;
}

- (void)playAnimationForKey:(NSString *)key expand:(BOOL)expand {
    NSArray *sprites = [self.spritesCache objectForKey:key];
    [self.mainButton.imageView setAnimationDuration:0.3];
    [self.mainButton.imageView setAnimationImages:sprites];
    self.mainButton.imageView.image = [sprites lastObject];
    [self.mainButton setImage:[sprites lastObject] forState:UIControlStateNormal];
    [self.mainButton.imageView startAnimatingWithCompletionBlock:^(BOOL success) {
        if (!expand) {
            [self resetMainButton];
        }
    }];
    [UIView animateWithDuration:0.1 animations:^{
        self.mainButton.transform = expand ? CGAffineTransformMakeScale(1.2, 1.2) : CGAffineTransformIdentity;
    } completion:nil];
}

- (void)swichMainButtonImage:(UIImage *)image {
    self.mainButton.imageView.image = image;
}

- (void)registSprites:(NSArray *)sprites forKey:(NSString *)key {
    if (!self.spritesCache) {
        self.spritesCache = [NSMutableDictionary dictionary];
    }
    [self.spritesCache setObject:sprites forKey:key];
}

- (void)registItemModule:(NavigationItemModule *)module forKey:(NSString *)key {
    if (!self.itemModuleCache) {
        self.itemModuleCache = [NSMutableDictionary dictionary];
    }
    [self.itemModuleCache setObject:module forKey:key];
}

- (void)resetItemImage:(UIImage *)image clickedImage:(UIImage *)clickedImage title:(NSString *)title atIndex:(NSInteger)index {
    CircleNavigationItem *item = [self.items objectAtIndex:index];
    [item updateWithImage:image highLightImage:clickedImage title:title];
}

- (NavigationItemModule *)dequeueModuleWithKey:(NSString *)key {
    if ([self.itemModuleCache objectForKey:key]) {
        return [self.itemModuleCache objectForKey:key];
    } else {
        assert(@"Error for use the key that was not register");
        return nil;
    }
}

#pragma mark - Actions

- (void)didClickMainButton {
    if ([self.delegate respondsToSelector:@selector(circleNavigationDidClickIcon:)]) {
        [self.delegate circleNavigationDidClickIcon:self];
    }
    [self showHideBackgroundButton:self.isPackUp];
    if (self.isPackUp) {
        for (CircleNavigationItem *item in self.items) {
            [item animateToTargetPostion];
        }
    } else {
        for (CircleNavigationItem *item in self.items) {
            [item animateToOriginPostion];
        }
    }
    self.isPackUp = !self.isPackUp;
}

- (void)didClickBackgroundButton {
    if ([self.delegate respondsToSelector:@selector(circleNavigationDidClickIcon:)]) {
        [self.delegate circleNavigationDidClickIcon:self];
    }
    [self showHideBackgroundButton:NO];
    for (CircleNavigationItem *item in self.items) {
        [item animateToOriginPostion];
    }
    self.isPackUp = YES;
}

#pragma mark - Private Method

- (void)resetMainButton {
    if ([self.datasource respondsToSelector:@selector(circleNavigationIconImage:)]) {
        [self.mainButton setImage:[UIImage imageNamed:[self.datasource circleNavigationIconImage:self]] forState:UIControlStateNormal];
    }
    if ([self.datasource respondsToSelector:@selector(circleNavigationIconClickedImage:)]) {
        [self.mainButton setImage:[UIImage imageNamed:[self.datasource circleNavigationIconClickedImage:self]] forState:UIControlStateHighlighted];
    }
}

- (void)setup {
    [self addBackgroundButton];
    [self addMainButton];
    [self reset];
}

- (void)clear {
    if (self.items) {
        [self removeAllItems];
        self.backgroundButton.hidden = YES;
        self.items = nil;
    }
}

- (void)removeAllItems {
    for (int i = 0; i < self.items.count; i ++) {
        CircleNavigationItem *item = [self.items objectAtIndex:i];
        [item pop_removeAllAnimations];
        if (item && [item superview]) {
            [item removeFromSuperview];
        }
    }
}

- (void)generateAllItems {
    NSInteger count = [self.datasource numberOfItemsInCircleNavigation:self];
    CGFloat startAngle = count < 3 ? ((M_PI_2 / count )/ 2.0) : 0.01;
    CGFloat averageAngle = count < 3 ? (M_PI_2 / count ) : M_PI_2 / (count - 1);
    self.items = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        CircleNavigationItem *item = [self generateSingleItemWithAngle:startAngle + i * averageAngle index:i];
        [self.items addObject:item];
    }
}

- (CircleNavigationItem *)generateSingleItemWithAngle:(CGFloat)angle index:(NSInteger)index {
    CircleNavigationConfig *config = [CircleNavigationConfig sharedConfig];
    NSString *key = [self.datasource circleNavigation:self itemKeyAtIndex:index];
    NavigationItemModule *itemModule = [self dequeueModuleWithKey:key];
    CircleNavigationItem *item = [CircleNavigationItem create];
    CGFloat offsetX = (config.iconSize.width - config.itemSize.width) / 2 + config.left;
    CGFloat offsetY = (config.iconSize.height - config.itemSize.height) / 2 + config.bottom;
    item.targetPostion = CGPointMake(config.radius * sin(angle) + offsetX, config.radius * cos(angle) + offsetY);
    item.originPostion = CGPointMake(offsetX, offsetY);
    item.angle = angle;
    [self insertSubview:item belowSubview:self.mainButton];
    [item setupWithImage:[UIImage imageNamed:itemModule.iconImageName] highLightImage:[UIImage imageNamed:itemModule.iconClickedImageName] title:itemModule.text];
    item.delegate = self;
    [self layoutIfNeeded];
    item.tag = index;
    return item;
}

#pragma mark -- Main Button

- (void)addMainButton {
    self.mainButton = [[UIButton alloc] init];
    [self addSubview:self.mainButton];
    [self.mainButton addTarget:self action:@selector(didClickMainButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureMainButton {
    [self resetMainButton];
    CircleNavigationConfig *config = [CircleNavigationConfig sharedConfig];
    CGSize size = config.iconSize;
    [self.mainButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@(config.left));
        make.bottom.equalTo(@(- config.bottom));
        make.width.equalTo(@(size.width));
        make.height.equalTo(@(size.height));
    }];
}

#pragma mark -- BackgroundButton

- (void)addBackgroundButton {
    self.backgroundButton = [[UIButton alloc] init];
    [self addSubview:self.backgroundButton];
    [self.backgroundButton addTarget:self action:@selector(didClickBackgroundButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureBackgroundButton {
    self.backgroundButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.backgroundButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    self.backgroundButton.hidden = YES;
}

- (void)showHideBackgroundButton:(BOOL)show {
    self.backgroundButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundButton.alpha = show ? 1 : 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.backgroundButton.hidden = !show;
        }
    }];
}

#pragma mark - CircleNavigationItem

- (void)circleNavigationItemDidClicked:(CircleNavigationItem *)circleNavigationItem {
    for (CircleNavigationItem *item in self.items) {
        [item animateToOriginPostion];
    }
    self.isPackUp = YES;
    [self showHideBackgroundButton:NO];
    __weak typeof(self) weakSelf = self;
    circleNavigationItem.packUpAnimationCompletion = ^(NSInteger index) {
        if ([weakSelf.delegate respondsToSelector:@selector(circleNavigation:didClickItemAtIndex:)]) {
            [weakSelf.delegate circleNavigation:self didClickItemAtIndex:index];
        }
    };
}

@end
