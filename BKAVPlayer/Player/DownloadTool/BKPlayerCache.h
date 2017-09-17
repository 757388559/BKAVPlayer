//
//  BKPlayerCache.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPlayerCache : NSObject

/**
 获取临时的缓存文件

 @param url 资源Url
 @return 路径
 */
+ (NSString *)cachePathForTempUrl:(NSURL *)url;

/**
 获取完整的缓存文件

 @param url 资源Url
 @return 路径
 */
+ (NSString *)cachePathForIntegralUrl:(NSURL *)url;
/**
 完整缓存文件的大小

 @param url 资源Url
 @return 资源大小
 */
+ (long long)cacheInteralFileSzie:(NSURL *)url;
/**
 本地是否存在完整的视频缓存

 @param url 要缓存的资源
 @return Y-存在
 */
+ (BOOL)existIntegralSourceForUrl:(NSURL *)url;


/**
 文件类型

 @param url Url
 @return 文件类型
 */
+ (NSString *)contentType:(NSURL *)url;

@end
