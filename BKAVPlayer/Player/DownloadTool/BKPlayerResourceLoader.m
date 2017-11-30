//
//  BKPlayerResourceLoader.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/20.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "BKPlayerResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import "NSURL+Scheme.h"
#import "BKPlayerCache.h"

@interface BKPlayerResourceLoader ()
<
VideoRequestTaskDelegate
>
/// Loading request array.
@property (nonatomic , strong) NSMutableArray *pendingRequestArray;
/// outPutStream.
@property (nonatomic , strong) NSOutputStream *outPutStream;
/// url.
@property (nonatomic , strong) NSURL *url;

@end

@implementation BKPlayerResourceLoader

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _pendingRequestArray = [@[] mutableCopy];
    }
    return self;
}

- (void)dealloc {
    
    [self.dataDownload invalidAndCacel];
    self.dataDownload.delegate = nil;
    self.dataDownload = nil;
    
}

#pragma mark - ResourceLoader data delegate 

// 资源加载代理的开始地方
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSURL *url = [loadingRequest.request.URL httpUrl];
    
    // 判断本地是否有完整缓存好的
    if ([BKPlayerCache existIntegralSourceForUrl:url]) {
        [self dealWithLoadingRequest:loadingRequest];
        return YES;
    }
    // 没有缓存好的数据要下载
    // 记录所有的请求
    [self.pendingRequestArray addObject:loadingRequest];
    
    // 获取请求的位置
    long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    
    if (requestedOffset != currentOffset) {
        requestedOffset = currentOffset;
    }

    // 如果没有下载：开始下载数据
    if (self.dataDownload.downloadedSize == 0) {
        [self.dataDownload downloadUrl:url offset:requestedOffset];
        return YES;
    }
    
    // 范围不匹配也要重新下载
    if (requestedOffset < self.dataDownload.offset ||
        requestedOffset > (self.dataDownload.downloadedSize + self.dataDownload.offset + 333)
        ) {
        [self.dataDownload downloadUrl:url offset:requestedOffset];
        return YES;
    }
    
    // 处理所有请求
    [self processPendingRequests];
    
    return YES;
}

// 取消资源请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.pendingRequestArray removeObject:loadingRequest];
}

// 处理下载中的文件
- (void)processPendingRequests {
    
    NSMutableArray *requestsCompleted = [NSMutableArray array];  //请求完成的数组
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequestArray)
    {
        // 填充 contentInformationRequest(头)信息
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.dataDownload.totalSize;
        NSString *contentType = self.dataDownload.mimeType;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 获取本地片段缓存数据
        NSData *data = [NSData dataWithContentsOfFile:[BKPlayerCache cachePathForTempUrl:url] options:NSDataReadingMappedIfSafe error:nil];
        // 对数据已经下载完后移动到完整缓存的判断
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[BKPlayerCache cachePathForIntegralUrl:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
        long long requetCurrentOffset = loadingRequest.dataRequest.currentOffset;
        long long requestLength = loadingRequest.dataRequest.requestedLength;
        
        if (requestedOffset != requetCurrentOffset) {
            requestedOffset = requetCurrentOffset;
        }
        
        long long responseOffset = requestedOffset-self.dataDownload.offset;
        
        // 可以提供给播放器的最小数据长度
        long long responseLength = MIN(self.dataDownload.offset + self.dataDownload.downloadedSize - requestedOffset, requestLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 判断每个数据片段是否完成
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [requestsCompleted addObject:loadingRequest];
        }
    }
    
    //在所有请求的数组中移除已经完成的
    [self.pendingRequestArray removeObjectsInArray:requestsCompleted];
}

// 本地已经下载好的文件
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSURL *url = [loadingRequest.request URL];
    long long totalSize = [BKPlayerCache cacheInteralFileSzie:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [BKPlayerCache contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 读取本地数据
    NSData *data = [NSData dataWithContentsOfFile:[BKPlayerCache cachePathForIntegralUrl:url] options:NSDataReadingMappedIfSafe error:nil];
    
    // player 需要的数据
    long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestedLength = loadingRequest.dataRequest.requestedLength;
    NSData *subData = [data subdataWithRange:NSMakeRange(requestedOffset, requestedLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    [loadingRequest finishLoading];

}


#pragma mark - Session task delegate

- (void)downloaddidFinished:(Download *)download {
    
    NSLog(@"片段下载结束");
}

- (void)download:(Download *)download didFailedWithErrorCode:(NSInteger)errorCode {
    NSLog(@"数据下载失败");
}

- (void)downloadDidReciveData:(Download *)download {
    
    [self processPendingRequests];
}




#pragma mark - setter and getter

- (Download *)dataDownload {
    
    if (!_dataDownload) {
        _dataDownload = [[Download alloc] init];
        _dataDownload.delegate = self;
    }
    return _dataDownload;
}

@end
