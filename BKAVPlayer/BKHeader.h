//
//  BKHeader
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/16.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#ifndef BKHeader
#define BKHeader


//#import "Masonry.h"

// 颜色宏定义
#define kRGBColor(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1]
#define kRGBAColor(r, g, b, a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:(a)]

#define PHONE_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define PHONE_HEIGH  ([UIApplication sharedApplication].statusBarFrame.size.height > 20 ? \
(([[UIScreen mainScreen] bounds].size.height - [UIApplication sharedApplication].statusBarFrame.size.height + 20)) : \
[[UIScreen mainScreen] bounds].size.height)

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define SS(strongSelf)  __strong __typeof(&*weakSelf)strongSelf = weakSelf;

#endif /* BKHeader */
