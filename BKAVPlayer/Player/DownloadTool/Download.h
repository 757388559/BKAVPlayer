//
//  Download.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Download;
@protocol VideoRequestTaskDelegate <NSObject>

- (void)didReceiveVideoDataWithTask:(Download *)task;
- (void)didFinishLoadingWithTask:(Download *)task;
- (void)didFailLoadingWithTask:(Download *)task WithError:(NSInteger )errorCode;

@end

@interface Download : NSObject

@property (nonatomic , strong, readonly) NSURL        *url;
@property (nonatomic , readonly        ) long long   offset;

@property (nonatomic , readonly        ) long long   totalSize;
@property (nonatomic , readonly        ) long long   downloadedSize;
@property (nonatomic , strong, readonly) NSString     *mimeType;
@property (nonatomic , assign)           BOOL         isFinishLoad;

@property (nonatomic , copy) NSString *fileName;

@property (nonatomic, weak            ) id <VideoRequestTaskDelegate> delegate;


- (void)downloadUrl:(NSURL *)url offset:(long long)offset;

- (void)cancelAndClean;

- (void)continueLoading;

@end
