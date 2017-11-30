//
//  Download.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "Download.h"
#import "BKPlayerCache.h"


@interface Download ()<NSURLSessionDelegate , NSURLSessionDataDelegate>


/// session.
@property (nonatomic , strong) NSURLSession *urlSession;
@property (nonatomic , strong) NSMutableArray  *taskArr;
/// outputStream.
@property (nonatomic , strong) NSOutputStream *outPutStream;
@property (nonatomic , assign) BOOL once;


@end

@implementation Download

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _taskArr = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    
    [self.outPutStream close];
    self.outPutStream = nil;
}

- (void)downloadUrl:(NSURL *)url offset:(long long)offset {
    
    _url = url;
    _offset = offset;
    
    [self cleanData];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-" ,offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request];
    [task resume];
    
}

- (void)cleanData {
    
    [self invalidAndCacel];
    [BKPlayerCache cleanCacheForTemp:self.url];
    _downloadedSize = 0;
    
}

- (void)invalidAndCacel {
    
    [self.urlSession invalidateAndCancel];
    self.urlSession = nil;
}


#pragma mark -  NSUrlSession Delegate Methods

//网络中断：-1005
//无网络连接：-1009
//请求超时：-1001
//服务器内部错误：-1004
//找不到服务器：-1003

/// 任何task 结束或者因为错误结束都会走
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
    
//        if (error.code == -1001 && !_once) {      //网络超时，重连一次
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self continueLoading];
//            });
//        }
//        if (error.code == -1009) {
//            NSLog(@"无网络连接");
//        }
//
        if (_delegate && [_delegate respondsToSelector:@selector(download:didFailedWithErrorCode:)]) {
            [_delegate download:self didFailedWithErrorCode:error.code];
        }
        
    } else {
        
        // 说明是完整的视频
        if ([BKPlayerCache cacheTempFileSize:_url] == self.totalSize) {
            [BKPlayerCache moveTempCahceFileToIntegralPathWithUrl:_url];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(downloaddidFinished:)]) {
            [_delegate downloaddidFinished:self];
        }
        
    }
    
}

/// 接受数据(周期性的调用)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    self.downloadedSize += data.length;
    [self.outPutStream write:data.bytes maxLength:data.length];
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadDidReciveData:)]) {
        [_delegate downloadDidReciveData:self];
    }
    
}

/// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *allHeadersFields = httpResponse.allHeaderFields;
        self.totalSize = [allHeadersFields[@"Content-Length"] longLongValue];
        NSString *contentRangeStr = allHeadersFields[@"Content-Range"];
        if (contentRangeStr.length != 0) {
            self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
        }
        self.mimeType = response.MIMEType;
        
    } else {
        self.mimeType = response.MIMEType;
        self.totalSize = response.expectedContentLength;
    }
    
    // 使用流写入
    self.outPutStream = [NSOutputStream outputStreamToFileAtPath:[BKPlayerCache cachePathForTempUrl:self.url] append:YES];
    [self.outPutStream open];
    completionHandler(NSURLSessionResponseAllow);
    
}



- (void)continueLoading {
    
    _once = YES;
  
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
//    
//    [request addValue:[NSString stringWithFormat:@"bytes=%lld-",(long long)_downloadedSize] forHTTPHeaderField:@"Range"];
    

}

#pragma mark - setter and getter

- (NSURLSession *)urlSession {
    
    if (!_urlSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _urlSession;
}



@end
