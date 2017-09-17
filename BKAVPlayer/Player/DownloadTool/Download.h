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

- (void)downloadDidReciveData:(Download *)download;
- (void)downloaddidFinished:(Download *)download;
- (void)download:(Download *)download didFailedWithErrorCode:(NSInteger)errorCode;

@end

@interface Download : NSObject

@property (nonatomic , strong) NSURL *url;

@property (nonatomic) long long offset;
@property (nonatomic) long long totalSize;
@property (nonatomic) long long downloadedSize;

@property (nonatomic , copy) NSString * mimeType;
@property (nonatomic , copy) NSString *fileName;

@property (nonatomic, weak) id<VideoRequestTaskDelegate> delegate;


- (void)downloadUrl:(NSURL *)url offset:(long long)offset;

- (void)cleanData;

- (void)continueLoading;

@end
