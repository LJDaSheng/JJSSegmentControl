//
//  JJSSegMentControl.h
//  JJSSegMentControl
//
//  Created by 贾菊盛 on 16/8/4.
//  Copyright © 2016年 贾菊盛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJSSegMentControl : UIControl
/// 标题数组
@property(nonatomic,strong)NSArray<NSString *> *titles;
/// 边框颜色
@property(nonatomic,strong)UIColor *backgroundBorderColor;
/// 选中的index
@property(nonatomic,assign)NSInteger selectedIndex;
/// 选中的背景
@property(nonatomic,strong)UIColor *selectedBackgroundColor;
/// 标题颜色
@property(nonatomic,strong)UIColor *titleColor;
/// 选中的标题颜色
@property(nonatomic,strong)UIColor *selectedTitleColor;
/// 标题字体
@property(nonatomic,strong)UIFont *titleFont;
/// 动画时长
@property(nonatomic,assign)NSTimeInterval animationDuration;
/// 弹簧效果
@property(nonatomic,assign)CGFloat animationSpringDamping;
@property(nonatomic,assign)CGFloat animationInitialSpringVelocity;
/// 切角角度
@property(nonatomic,assign)CGFloat segCornerRadius;
+ (instancetype)setMentControlWithTitles:(NSArray<NSString *> *)titles;
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles;
@end
