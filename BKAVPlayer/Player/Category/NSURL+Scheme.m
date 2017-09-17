//
//  NSURL+Scheme.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/9/17.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "NSURL+Scheme.h"

@implementation NSURL (Scheme)


- (NSURL *)streamingScheme {
    
    NSURLComponents *comments = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    comments.scheme = @"streaming";
    return comments.URL;
}

- (NSURL *)httpScheme {
    
    NSURLComponents *comments = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    comments.scheme = @"http";
    return comments.URL;
}

@end
