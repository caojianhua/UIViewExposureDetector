//
//  UIView+Detect.h
//  UIViewDetect
//
//  Created by jianhua on 2017/6/5.
//  Copyright © 2017年 jianhua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCDetect)

// 是否设置为可见属性
- (BOOL)cc_isVisible;

// 检测view的曝光比例
// 如果view被其他视图遮挡一半则返回0.5
// 如果view全部被展示则返回1.0
// 如果view全部被遮挡或者不可见则返回0
- (float)cc_exposureRatio;

@end
