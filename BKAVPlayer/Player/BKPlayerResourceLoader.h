//
//  BKPlayerResourceLoader.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/20.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class BKPlayerResourceLoader;
@protocol BKPlayerRquestTaskDelegate <NSObject>


@end

@interface BKPlayerResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

/// url.
@property (nonatomic , strong ,readonly) NSURL *url;
/// offset.
@property (nonatomic , readonly) NSUInteger offset;
/// video Length.
@property (nonatomic , readonly) NSUInteger videolength;
/// 下载的偏移量.
@property (nonatomic , readonly) NSUInteger downLoadingOffset;
/// 类型.
@property (nonatomic , strong, readonly) NSString *mimeType;
/// 结束load.
@property (nonatomic , assign) BOOL isFinishLoad;
/// Delegate
@property (nonatomic , weak) id <BKPlayerRquestTaskDelegate> delegate;

- (NSURL *)getSchemeVideoUrl:(NSURL *)url;
- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;
- (void)cancel;
- (void)continueLoading;
- (void)clearData;


@end
