//
//  CircleNavigationItem.m
//  CircleNavigation
//
//  Created by guoshencheng on 11/23/15.
//  Copyright © 2015 guoshencheng. All rights reserved.
//

#import "CircleNavigationItem.h"
#import "CircleNavigation.h"


static NSString *const kCircleNavigationPopPropertyName = @"pop.animtion.circlenavigation";
static NSString *const kCircleNavigationPopSpringAnimation = @"circle_navigation_popSpringAnimation";

@interface CircleNavigationItem()

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *labelViewContainerView;
@property (weak, nonatomic) IBOutlet UIButton *itemButton;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelViewLeftConstraint;

@property (strong, nonatomic) MASConstraint *leftConstraint;
@property (strong, nonatomic) MASConstraint *bottomConstraint;
@property (assign, nonatomic) CGFloat transitionProgress;

@end

@implementation POPAnimatableProperty (CircleNavigationItem)

CGFloat getLayoutConstant(MASConstraint* constraint) {
    return (CGFloat)[[constraint valueForKey:@"layoutConstant"] floatValue];
}

+ (POPAnimatableProperty*) mas_offsetProperty {
    return [POPAnimatableProperty propertyWithName:@"offset" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(MASConstraint *constraint, CGFloat values[]) {
            values[0] = getLayoutConstant(constraint);
        };
        
        prop.writeBlock = ^(MASConstraint *constraint, const CGFloat values[]) {
            [constraint setOffset:values[0]];
        };
    }];
}

@end

@implementation CircleNavigationItem

#pragma mark - PublicMethod

+ (instancetype)create {
    CircleNavigationItem *circleNavigationItem = [[[NSBundle mainBundle] loadNibNamed:@"CircleNavigationItem" owner:nil options:nil] lastObject];
    circleNavigationItem.translatesAutoresizingMaskIntoConstraints = NO;
    return circleNavigationItem;
}

- (void)setupWithImage:(UIImage *)image highLightImage:(UIImage *)highLightImage title:(NSString *)title {
    [self updateWithImage:image highLightImage:highLightImage title:title];
    [self configureConstraint];
}

- (void)updateWithImage:(UIImage *)image highLightImage:(UIImage *)highLightImage title:(NSString *)title {
    self.itemImageView.backgroundColor = [UIColor clearColor];
    [self.itemButton setImage:image forState:UIControlStateNormal];
    self.label.text = title;
    [self.itemButton setImage:highLightImage forState:UIControlStateHighlighted];
}

- (void)animateToTargetPostion {
    self.hidden = NO;
    POPSpringAnimation *animation = [self popSpringAnimation];
    animation.toValue = @(1);
    animation.springBounciness = 15.0f;
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [self springAnimatePopLabelView];
    };
}

- (void)animateToOriginPostion {
    if (self.labelViewLeftConstraint.constant > 20) {
        self.labelViewLeftConstraint.constant = 20;
    }
    [self pop_removeAnimationForKey:kCircleNavigationPopSpringAnimation];
    [self baseAnimatePopLabelViewWithBlock:^(POPAnimation *anim, BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transitionProgress = 0;
        } completion:^(BOOL finished) {
            if (self.packUpAnimationCompletion) {
                self.packUpAnimationCompletion(self.tag);
                self.packUpAnimationCompletion = nil;
            }
            self.hidden = YES;
        }];
//        POPSpringAnimation *animation = [self popSpringAnimation];
//        animation.toValue = @(0);
//        animation.springBounciness = 0.0f;
//        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
//            if (self.packUpAnimationCompletion) {
//                self.packUpAnimationCompletion(self.tag);
//                self.packUpAnimationCompletion = nil;
//            }
//            self.hidden = YES;
//        };
    }];
}

#pragma mark - PrivateMethod

- (void)configureConstraint {
    self.hidden = YES;
    CircleNavigationConfig *config = [CircleNavigationConfig sharedConfig];
    CGFloat width = config.itemSize.width;
    CGFloat height = config.itemSize.height;
    __weak typeof(self) weakSelf = self;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        self.leftConstraint = make.left.equalTo(@(weakSelf.originPostion.x));
        self.bottomConstraint = make.bottom.equalTo(@(-weakSelf.originPostion.y));
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
    }];
    self.labelViewLeftConstraint.constant = -80;
    [self layoutIfNeeded];
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.labelViewContainerView.layer.cornerRadius = self.frame.size.height / 2;
    self.itemButton.transform = CGAffineTransformMakeRotation(M_PI_2 - self.angle);
    self.transform = CGAffineTransformMakeRotation(self.angle - M_PI_2);
    self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress {
    if (transitionProgress < 0) {
        transitionProgress = 0;
    }
    _transitionProgress = transitionProgress;
    [self updateCurrentPosition];
    [self updateCurrentAlpha];
    [self layoutIfNeeded];
}

- (void)updateCurrentPosition {
    CGFloat currentX = [CircleNavigationItem valueWithProgress:_transitionProgress startValue:self.originPostion.x toValue:self.targetPostion.x];
    CGFloat currentY = [CircleNavigationItem valueWithProgress:_transitionProgress startValue:self.originPostion.y toValue:self.targetPostion.y];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        self.leftConstraint = make.left.equalTo(@(currentX));
        self.bottomConstraint = make.bottom.equalTo(@(- currentY));
    }];
}

- (void)updateCurrentAlpha {
    self.alpha = [CircleNavigationItem valueWithProgress:_transitionProgress startValue:-0.2 toValue:1];
}

#pragma mark - Animation

- (POPSpringAnimation *)popSpringAnimation {
    POPSpringAnimation *animation;
    if ([self pop_animationForKey:kCircleNavigationPopSpringAnimation]) {
        animation = [self pop_animationForKey:kCircleNavigationPopSpringAnimation];
    } else {
        animation = [POPSpringAnimation new];
        animation.property = [self springAnimationProperty];
        animation.springSpeed = 40.0f;
        [self pop_addAnimation:animation forKey:kCircleNavigationPopSpringAnimation];
    }
    return animation;
}

- (POPAnimatableProperty *)springAnimationProperty {
    POPAnimatableProperty *springAnimationProperty = [POPAnimatableProperty propertyWithName:kCircleNavigationPopPropertyName initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj transitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return springAnimationProperty;
}

- (void)baseAnimatePopLabelViewWithBlock:(void (^)(POPAnimation *anim, BOOL finished))block{
    POPBasicAnimation *layoutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.duration = 0.1;
    layoutAnimation.toValue = @(-80);
    layoutAnimation.completionBlock = block;
    [self.labelViewLeftConstraint pop_addAnimation:layoutAnimation forKey:@"leftConstraint"];
}

- (void)springAnimatePopLabelView {
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 30.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(20);
    [self.labelViewLeftConstraint pop_addAnimation:layoutAnimation forKey:@"leftConstraint"];
}

- (IBAction)didClickItem:(id)sender {
    if ([self.delegate respondsToSelector:@selector(circleNavigationItemDidClicked:)]) {
        [self.delegate circleNavigationItemDidClicked:self];
    }
}

+ (CGFloat)valueWithProgress:(CGFloat)progress startValue:(CGFloat)startValue toValue:(CGFloat)toValue {
    return startValue + (toValue - startValue) * progress;
}

@end
