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

- (void)task:(Download *)task didReceiveVideoLength:(NSUInteger)ideoLength mimeType:(NSString *)mimeType;
- (void)didReceiveVideoDataWithTask:(Download *)task;
- (void)didFinishLoadingWithTask:(Download *)task;
- (void)didFailLoadingWithTask:(Download *)task WithError:(NSInteger )errorCode;

@end

@interface Download : NSObject

@property (nonatomic , strong, readonly) NSURL        *url;
@property (nonatomic , readonly        ) NSUInteger   offset;

@property (nonatomic , readonly        ) NSUInteger   videoLength;
@property (nonatomic , readonly        ) NSUInteger   downLoadingOffset;
@property (nonatomic , strong, readonly) NSString     *mimeType;
@property (nonatomic , assign)           BOOL         isFinishLoad;

@property (nonatomic , copy) NSString *fileName;

@property (nonatomic, weak            ) id <VideoRequestTaskDelegate> delegate;


- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

- (void)cancel;

- (void)continueLoading;

- (void)clearData;

@end
