//
//  ViewController.m
//  JJSSegMentControl
//
//  Created by 贾菊盛 on 16/8/3.
//  Copyright © 2016年 贾菊盛. All rights reserved.
//

#import "ViewController.h"
#import "JJSSegMentControl.h"
@interface ViewController ()
@property(nonatomic,strong)UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JJSSegMentControl *seg = [[JJSSegMentControl alloc]initWithTitles:@[@"你们",@"我们",@"他们"]];
    seg.selectedBackgroundColor = [UIColor whiteColor];
    seg.backgroundColor = [UIColor orangeColor];
    seg.titleColor = [UIColor whiteColor];
    seg.selectedTitleColor = [UIColor orangeColor];
    seg.animationDuration = 0.5;
    seg.frame = CGRectMake(0, 100, 300, 50);
    seg.segCornerRadius = 24;
    seg.titleFont = [UIFont boldSystemFontOfSize:20];
    [seg addTarget:self action:@selector(segChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];
    
    [self.view addSubview:self.label];
}
- (void)segChange:(JJSSegMentControl *)sender{
    NSLog(@"%td",sender.selectedIndex);
    self.label.text = [NSString stringWithFormat:@"选中 %td",sender.selectedIndex];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.frame = CGRectMake(100, 300, 100, 50);
        _label.backgroundColor = [UIColor orangeColor];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}
@end
