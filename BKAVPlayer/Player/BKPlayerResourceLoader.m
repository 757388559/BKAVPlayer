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

#import "BKPlayerCachePath.h"

@interface BKPlayerResourceLoader ()
<NSURLSessionDataDelegate,
NSURLSessionTaskDelegate,
VideoRequestTaskDelegate
>

@property (nonatomic , strong) NSString *tempVideoCachePath;
@property (nonatomic , assign) NSUInteger expectedSize;
@property (nonatomic , assign) NSUInteger receiveredSize;
/// Loading request array.
@property (nonatomic , strong) NSMutableArray *pendingRequestArray;
@property (nonatomic, copy) NSString *videoPath;
///.
@property (nonatomic , strong) BKPlayerCachePath *videoCachaPath;
@end

@implementation BKPlayerResourceLoader

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _pendingRequestArray = [@[] mutableCopy];
    }
    return self;
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest {
    
    NSString *mimeType = self.dataDownload.mimeType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.dataDownload.videoLength;
}

- (NSURL *)getSchemeVideoUrl:(NSURL *)url {
    
    NSURLComponents *component = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    component.scheme = @"streaming";
    return [component URL];
}


#pragma mark - ResourceLoader data delegate 

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSLog(@"resourceLoader wait For Loading");
    
    [self.pendingRequestArray addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSLog(@"resourceLoader did cancel Loading");
    [self.pendingRequestArray removeObject:loadingRequest];
}


- (void)processPendingRequests {
    
    NSMutableArray *requestsCompleted = [NSMutableArray array];  //请求完成的数组
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequestArray)
    {
        [self fillInContentInformation:loadingRequest.contentInformationRequest]; //对每次请求加上长度，文件类型等信息
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest]; //判断此次请求的数据是否处理完全
        
        if (didRespondCompletely) {
            
            [requestsCompleted addObject:loadingRequest];  //如果完整，把此次请求放进 请求完成的数组
            [loadingRequest finishLoading];
            
        }
    }
    
    [self.pendingRequestArray removeObjectsInArray:requestsCompleted];   //在所有请求的数组中移除已经完成的
}

- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSLog(@"resourceLoadingRequest:%@" , loadingRequest);
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);

    if (self.dataDownload.downLoadingOffset > 0) {
        [self processPendingRequests];
    } else  {
        [self.dataDownload setUrl:interceptedURL offset:0];
    }
    
//    if (!self.dataDownload) {
//        self.dataDownload = [[Download alloc] init];
//        self.dataDownload.delegate = self;
//        [self.dataDownload setUrl:interceptedURL offset:0];
//    } else {
        // 如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
        if (self.dataDownload.offset + self.dataDownload.downLoadingOffset + 1024 * 300 < range.location ||
            // 如果往回拖也重新请求
            range.location < self.dataDownload.offset) {
            [self.dataDownload setUrl:interceptedURL offset:range.location];
        }
//    }
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    long long startOffset = dataRequest.requestedOffset;
    
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    if ((self.dataDownload.offset +self.dataDownload.downLoadingOffset) < startOffset)
    {
        //NSLog(@"NO DATA FOR REQUEST");
        return NO;
    }
    
    if (startOffset < self.dataDownload.offset) {
        return NO;
    }
    
    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.dataDownload.downLoadingOffset - ((NSInteger)startOffset - self.dataDownload.offset);
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset- self.dataDownload.offset, (NSUInteger)numberOfBytesToRespondWith)]];
 
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = (self.dataDownload.offset + self.dataDownload.downLoadingOffset) >= endOffset;
    
    return didRespondFully;
}

#pragma mark - Session task delegate

- (void)task:(Download *)task didReceiveVideoLength:(NSUInteger)ideoLength mimeType:(NSString *)mimeType {

}

- (void)didReceiveVideoDataWithTask:(Download *)task {

//    NSLog(@"task delegate ReciveData");
    [self processPendingRequests];
}

- (void)didFinishLoadingWithTask:(Download *)task {
    
}

//网络中断：-1005
//无网络连接：-1009
//请求超时：-1001
//服务器内部错误：-1004
//找不到服务器：-1003
- (void)didFailLoadingWithTask:(Download *)task WithError:(NSInteger )errorCode {

//    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
//        [self.delegate didFailLoadingWithTask:task WithError:errorCode];
//    }
    
}


#pragma mark - setter and getter

- (Download *)dataDownload {
    
    if (!_dataDownload) {
        _dataDownload = [[Download alloc] init];
        _dataDownload.delegate = self;
    }
    return _dataDownload;
}



- (NSString *)videoPath {
    
    if (!self.videoCachaPath) {
        self.videoCachaPath = [[BKPlayerCachePath alloc] init];
    }
    return [self.videoCachaPath videoPathWithTemporaryFile:self.dataDownload.fileName];
}

@end
