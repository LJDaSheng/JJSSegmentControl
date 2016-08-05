//
//  JJSSegMentControl.m
//  JJSSegMentControl
//
//  Created by 贾菊盛 on 16/8/4.
//  Copyright © 2016年 贾菊盛. All rights reserved.
//

#import "JJSSegMentControl.h"
@interface JJSSegMentControl()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)NSMutableArray <UILabel *>*titleLabels;
@property(nonatomic,strong)NSMutableArray <UILabel *>*selectedTitleLabels;
/// 初始容器视图
@property(nonatomic,strong)UIView *titleLabelsContentView;
/// 选中的容器视图
@property(nonatomic,strong)UIView *selectedTitleLabelsContentView;
/// 选中的背景view
@property(nonatomic,strong)UIView *selectedBackgroundView;
/// 遮照视图
@property(nonatomic,strong)UIView *titleMaskView;
/// 轻点手势
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
/// 滑动手势
@property(nonatomic,strong)UIPanGestureRecognizer *panGesture;
/// 选中视图的边框
@property(nonatomic,assign)CGFloat selectedBackgroundInset;
/// 记录初始frame
@property(nonatomic)CGRect initialSelectedBackgroundViewFrame;
@end
@implementation JJSSegMentControl
+ (instancetype)setMentControlWithTitles:(NSArray<NSString *> *)titles{
    JJSSegMentControl *seg = [[JJSSegMentControl alloc]initWithTitles:titles];
    return seg;
}
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles{
    if (self = [super init]) {
        self.animationSpringDamping = 0.75;
        self.animationInitialSpringVelocity = 0.0;
        
        self.selectedIndex = 0;
        self.titles = titles;
        [self finishInit];
    }
    return self;
}

- (void)finishInit{
    [self addSubview:self.titleLabelsContentView];
    [self addSubview:self.selectedBackgroundView];
    [self addSubview:self.selectedTitleLabelsContentView];
    // 设置默认颜色
    self.titleMaskView.backgroundColor = [UIColor redColor];
    self.selectedBackgroundColor = [UIColor whiteColor];
    self.titleColor = [UIColor whiteColor];
    self.selectedTitleColor = [UIColor blackColor];
    self.selectedTitleLabelsContentView.layer.mask = self.titleMaskView.layer;
    
    self.selectedBackgroundInset = 2.0;
    // 手势
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGesture];
     self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:self.panGesture];
    self.panGesture.delegate = self;
    
    /// KVO
    [self addObserver:self forKeyPath:@"selectedBackgroundView.frame" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:@"selectedBackgroundView.frame"];
}
 // 轻触
- (void)tapped:(UITapGestureRecognizer *)sender{
    CGPoint location =  [sender locationInView:self];
    NSInteger index = (NSInteger)location.x/(self.bounds.size.width/self.titleLabels.count);
    [self setSelectedIndex:index animation:YES];
}
// 滑动
- (void)pan:(UIPanGestureRecognizer *)sender{
    CGFloat w = self.bounds.size.width;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.initialSelectedBackgroundViewFrame = self.selectedBackgroundView.frame;
            break;
        case UIGestureRecognizerStateChanged:
            {
                CGRect rect = self.initialSelectedBackgroundViewFrame;
                rect.origin.x += [sender translationInView:self].x;
                rect.origin.x = MAX(MIN(rect.origin.x,w- self.selectedBackgroundInset - rect.size.width) , self.selectedBackgroundInset);
                self.selectedBackgroundView.frame = rect;
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat f =roundf(self.selectedBackgroundView.frame.origin.x/(CGFloat)(w/self.titleLabels.count));
            NSInteger index =  MIN(self.titleLabels.count-1, f);
            NSInteger selectIndex = MAX(0,index);
            [self setSelectedIndex:selectIndex animation:YES];
        }
            break;
        default:
            break;
    }
}

- (void)setSelectedIndex:(NSInteger )selectedIndex animation:(BOOL)animation{
    if (self.titleLabels.count < selectedIndex) {
        return;
    }
    
    BOOL catchHalfSwitch = NO;
    if (self.selectedIndex == selectedIndex) {
        catchHalfSwitch = YES;
    }
    self.selectedIndex = selectedIndex;

    if (animation) {
        if(!catchHalfSwitch){
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        [UIView animateWithDuration:self.animationDuration delay:0.0 usingSpringWithDamping:self.animationSpringDamping initialSpringVelocity:self.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            [self layoutSubviews];
        } completion:nil];
    }else{
        // 更新布局
        [self layoutSubviews];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"selectedBackgroundView.frame"]) {
        self.titleMaskView.frame = self.selectedBackgroundView.frame;
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat itemWidth = self.bounds.size.width/self.titleLabels.count;
    
    CGFloat selectedBackgroundWidth = itemWidth - self.selectedBackgroundInset *2.0;
    CGFloat selectedBackgroundHeight = self.bounds.size.height - self.selectedBackgroundInset * 2.0;
    self.selectedBackgroundView.frame = CGRectMake(self.selectedBackgroundInset + self.selectedIndex * itemWidth , self.selectedBackgroundInset, selectedBackgroundWidth, selectedBackgroundHeight);
    
    self.titleLabelsContentView.frame = self.bounds;
    self.selectedTitleLabelsContentView.frame = self.bounds;
    
    for (UILabel *label in self.titleLabels) {
        NSUInteger index = [self.titleLabels indexOfObject:label];
        CGPoint point = CGPointMake(itemWidth * index + self.selectedBackgroundInset, self.selectedBackgroundInset);
        CGRect frame = CGRectMake(point.x, point.y, selectedBackgroundWidth, selectedBackgroundHeight);
        label.frame = frame;
    }
    
    for (UILabel *label in self.selectedTitleLabels) {
        NSUInteger index = [self.selectedTitleLabels indexOfObject:label];
        CGPoint point = CGPointMake(itemWidth * index + self.selectedBackgroundInset, self.selectedBackgroundInset);
        CGRect frame = CGRectMake(point.x, point.y, selectedBackgroundWidth, selectedBackgroundHeight);
        label.frame = frame;
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGesture) {
        return CGRectContainsPoint(self.selectedBackgroundView.frame, [gestureRecognizer locationInView:self]);
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}
#pragma mark- setter
- (void)setTitles:(NSArray<NSString *> *)titles{
    _titles = titles;
    [self.titleLabels removeAllObjects];
    [self.selectedTitleLabels removeAllObjects];
    
    for (NSString *title in titles) {
        UILabel *label = [[UILabel alloc]init];
        label.text = title;
        label.font = self.titleFont?:[UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.titleLabelsContentView addSubview:label];
        [self.titleLabels addObject:label];
    }
    
    for (NSString *title in titles) {
        UILabel *label = [[UILabel alloc]init];
        label.text = title;
        label.font = self.titleFont?:[UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.selectedTitleLabelsContentView addSubview:label];
        [self.selectedTitleLabels addObject:label];
    }
}
- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    for (UILabel *label in self.titleLabels) {
        label.textColor = _titleColor;
    }
}
- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor{
    _selectedTitleColor = selectedTitleColor;
    for (UILabel *label in self.selectedTitleLabels) {
        label.textColor = _selectedTitleColor;
    }
}
- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor{
    _selectedBackgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView.backgroundColor = _selectedBackgroundColor;
}
- (void)setSelectedBackgroundInset:(CGFloat)selectedBackgroundInset{
    _selectedBackgroundInset = selectedBackgroundInset;
    [self setNeedsLayout];
}
- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    for (UILabel *label in self.titleLabels) {
        label.font = _titleFont;
    }
    for (UILabel *label in self.selectedTitleLabels) {
        label.font = _titleFont;
    }
}
- (void)setSegCornerRadius:(CGFloat)segCornerRadius{
    _segCornerRadius = segCornerRadius;
    self.selectedBackgroundView.layer.cornerRadius = _segCornerRadius;
    self.titleMaskView.layer.cornerRadius = _segCornerRadius;
    self.layer.cornerRadius = _segCornerRadius;
}
- (void)setBackgroundBorderColor:(UIColor *)backgroundBorderColor{
    _backgroundBorderColor = backgroundBorderColor;
    self.layer.borderColor = [_backgroundBorderColor CGColor
                              ];
    self.layer.borderWidth = self.selectedBackgroundInset+0.5;
}
#pragma mark- 懒加载
- (NSMutableArray<UILabel *> *)titleLabels{
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}
- (NSMutableArray<UILabel *> *)selectedTitleLabels{
    if (!_selectedTitleLabels) {
        _selectedTitleLabels = [NSMutableArray array];
    }
    return _selectedTitleLabels;
}
- (UIView *)titleLabelsContentView{
    if (!_titleLabelsContentView) {
        _titleLabelsContentView = [[UIView alloc]init];
    }
    return _titleLabelsContentView;
}
- (UIView *)selectedBackgroundView{
    if (!_selectedBackgroundView) {
        _selectedBackgroundView = [[UIView alloc]init];
    }
    return _selectedBackgroundView;
}
- (UIView *)selectedTitleLabelsContentView{
    if (!_selectedTitleLabelsContentView) {
        _selectedTitleLabelsContentView = [[UIView alloc]init];
    }
    return _selectedTitleLabelsContentView;
}
- (UIView *)titleMaskView{
    if (!_titleMaskView) {
        _titleMaskView = [[UIView alloc]init];
        
    }
    return _titleMaskView;
}
@end
