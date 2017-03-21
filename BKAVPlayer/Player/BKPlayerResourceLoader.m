//
//  BKPlayerResourceLoader.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/20.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "BKPlayerResourceLoader.h"

#import <UIKit/UIKit.h>

@interface BKPlayerResourceLoader ()
<NSURLSessionDataDelegate,
NSURLSessionTaskDelegate>

@property (nonatomic , strong) NSString *tempVideoCachePath;
@property (nonatomic , assign) NSUInteger expectedSize;
@property (nonatomic , assign) NSUInteger receiveredSize;


@end

@implementation BKPlayerResourceLoader

- (instancetype)init {
    
    self = [super init];
    if (self) {
       
    }
    return self;
}


#pragma mark - ResourceLoader data delegate 

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    
    
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    
}

#pragma mark - Session task delegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    //'304 Not Modified' is an exceptional one.
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        
        NSInteger expected = MAX((NSInteger)response.expectedContentLength, 0);
        self.expectedSize = expected;
        
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }

    }
    else {
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode;
        
        // This is the case when server returns '304 Not Modified'. It means that remote video is not changed.
        // In case of 304 we need just cancel the operation and return cached video from the cache.
//        if (code == 304) {
//            [self cancelInternal];
//        } else {
//            [self.dataTask cancel];
//        }
//        
//        [self done];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    self.receiveredSize += data.length;
    
    @autoreleasepool {
       
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    
}

- (NSURL *)getSchemeVideoUrl:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
//    components.scheme = @"streaming";
    return [components URL];
}

#pragma mark - setter and getter

//- (NSURLSession *)session {
//    
//    if (!_session) {
//        
//        NSURLSessionConfiguration *configuration = nil;
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@""];
//        } else {
//            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@""];
//        }
//        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    }
//    return _session;
//}

@end
