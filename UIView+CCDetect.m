//
//  UIView+Detect.m
//  UIViewDetect
//
//  Created by jianhua on 2017/6/5.
//  Copyright © 2017年 jianhua. All rights reserved.
//

#import "UIView+CCDetect.h"

@implementation UIView (CCDetect)

- (UIViewController *)cc_parentViewController {
  UIResponder *parentResponder = self;

  while (parentResponder != nil) {
    parentResponder = parentResponder.nextResponder;

    if ([parentResponder isKindOfClass:[UIViewController class]]) {
      UIViewController *ctrl = (UIViewController *)parentResponder;
      return ctrl;
    }
  }

  return nil;
}

- (void)cc_recursionSubViews:(UIView *)superView
           intoSubViewIndexs:(NSMutableDictionary *)indexSet
            withCurrentIndex:(NSString *)index {

  if (![superView isKindOfClass:[UIView class]]) {
    return;
  }

  NSArray *subViews = superView.subviews;

  // 先添加自己
  [indexSet setObject:superView forKey:index];

  for (int i = 0; i < subViews.count; i++) {

    UIView *item = subViews[i];
    if (![item isKindOfClass:[UIView class]]) {
      continue;
    }

    NSString *itemIndex = [NSString stringWithFormat:@"%@.%d", index, i];

    if (item.subviews.count > 0) {
      [self cc_recursionSubViews:item
               intoSubViewIndexs:indexSet
                withCurrentIndex:itemIndex];
    } else {
      [indexSet setObject:item forKey:itemIndex];
    }
  }
  
}

- (BOOL)cc_isVisible {
  if (self.window == nil) {
    return NO;
  }

  if (self.hidden == YES) {
    return NO;
  }

  if (self.frame.size.width <= 1 || self.frame.size.height <= 1) {
    return NO;
  }

  if (self.alpha <= 0.01f) {
    return NO;
  }

  if (self.opaque == NO) {
    return NO;
  }

  if (self.layer.opacity <= 0.01f) {
    return NO;
  }

  return YES;
}

- (float)cc_exposureRatio {

  NSMutableDictionary *viewIndexSet = [[NSMutableDictionary alloc] init];
  UIView *superTopView = [self cc_parentViewController].view;

  [self cc_recursionSubViews:superTopView intoSubViewIndexs:viewIndexSet withCurrentIndex:@"0"];

  NSString *selfIndex = [viewIndexSet allKeysForObject:self].firstObject;


  CGFloat exposureRatio = 1.0f;

  for (NSString *index in viewIndexSet.allKeys) {

    // is super
    if ([selfIndex hasPrefix:index]) {
      continue;
    }

    // is top
    UIView *topView = nil;

    NSArray<NSString *> *indexItems = [index componentsSeparatedByString:@"."];
    NSArray<NSString *> *selfIndexItems = [selfIndex componentsSeparatedByString:@"."];

    for (int i = 0; i < MIN(indexItems.count, selfIndexItems.count); i++) {
      if (indexItems[i].integerValue > selfIndexItems[i].integerValue) {
        topView = [viewIndexSet objectForKey:index];
        break;
      }
    }

    // 覆盖在上层的View只有可见状态才参与计算
    if (topView && [topView cc_isVisible]) {

      CGRect topRect = [topView convertRect:topView.bounds toView:superTopView];
      CGRect selfRect = [self convertRect:self.bounds toView:superTopView];
      CGRect superTopRect = [superTopView convertRect:superTopView.bounds toView:superTopView];

      CGRect topRectCut = CGRectIntersection(topRect, superTopRect);
      if (CGRectIsNull(topRectCut)) {
        topRectCut = topRect;
      }

      CGRect selfRectCut = CGRectIntersection(selfRect, superTopRect);
      if (CGRectIsNull(selfRectCut)) {
        selfRectCut = selfRect;
      }

      CGRect intersection = CGRectIntersection(topRectCut, selfRectCut);
      if (CGRectIsNull(intersection)) {
        CGFloat ratio = (selfRectCut.size.width * selfRectCut.size.height) / (selfRect.size.width * selfRect.size.height);
        exposureRatio = MIN(exposureRatio, ratio);
      } else {
        CGFloat ratio = 1 - (intersection.size.width * intersection.size.height) / (selfRect.size.width * selfRect.size.height);
        exposureRatio = MIN(exposureRatio, ratio);
      }
    }
    
  }
  
  return exposureRatio;
}

@end
