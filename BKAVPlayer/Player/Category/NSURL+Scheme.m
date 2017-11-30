//
//  NSURL+Scheme.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/9/17.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "NSURL+Scheme.h"

@implementation NSURL (Scheme)


- (NSURL *)streamUrl {
    
    NSURLComponents *comments = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    comments.scheme = @"streaming";
    return comments.URL;
}

- (NSURL *)httpUrl {
    
    NSURLComponents *comments = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    comments.scheme = @"http";
    return comments.URL;
}

- (NSURL *)httpsUrl {
    
    NSURLComponents *comments = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    comments.scheme = @"https";
    return comments.URL;
}

@end
