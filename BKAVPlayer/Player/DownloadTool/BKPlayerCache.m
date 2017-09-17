//
//  BKPlayerCache.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "BKPlayerCache.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define tempPath NSTemporaryDirectory()
#define docsPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
NSString * const BKVideoCacheForTemporaryPath = @"/videoTempCacheFile";
NSString * const BKVideoCacheForIntegralPath = @"/videoIntegralCacheFile"; // 缓存完的视频路径

@interface BKPlayerCache ()

@end

@implementation BKPlayerCache

// 临时缓存文件夹
+ (NSString *)cacheTempPath {
    
    NSString *path = [tempPath stringByAppendingPathComponent:BKVideoCacheForTemporaryPath];
    BOOL isDir ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

// 完整缓存文件夹
+ (NSString *)cacheInteralPath {
    
    NSString *path = [docsPath stringByAppendingPathComponent:BKVideoCacheForIntegralPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

// 完整缓存文件大小
+ (long long)cacheInteralFileSzie:(NSURL *)url {
    
    if ([self existIntegralSourceForUrl:url]) {
        NSString *path = [self cachePathForIntegralUrl:url];
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        return [fileDic[NSFileSize] longLongValue];
    }
    return 0;
}

// 是否存在缓存好的完整文件
+ (BOOL)existIntegralSourceForUrl:(NSURL *)url {
    
    NSString *fileName = [url lastPathComponent];
    NSString *filePath = [[self cacheInteralPath] stringByAppendingPathComponent:fileName];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        
        if (isDir) {
            return NO;
        } else {
            return YES;
        }
        
    }
    return NO;
}

+ (NSString *)cachePathForIntegralUrl:(NSURL *)url {
    
    return [[self cacheInteralPath] stringByAppendingPathComponent:url.lastPathComponent];
}


+ (NSString *)cachePathForTempUrl:(NSURL *)url {
    
    return [[self cacheTempPath] stringByAppendingPathComponent:url.lastPathComponent];
}



+ (NSString *)contentType:(NSURL *)url {
    
    NSString *path = [self cachePathForIntegralUrl:url];
    NSString *fileExtension = path.pathExtension;
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);;
    return contentType;
}

@end
