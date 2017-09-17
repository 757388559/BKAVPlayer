//
//  NSURL+Scheme.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/9/17.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Scheme)

- (NSURL *)streamUrl;
- (NSURL *)httpUrl;

@end
