//
//  BKPlayerCachePath.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "BKPlayerCachePath.h"

NSString * const BKVideoCacheForTemporaryFile = @"/VideoTemporaryFile";
NSString * const BKVideoCacheForIncompleteFile = @"/VideoIncompleteFile";

@interface BKPlayerCachePath ()

/// FileManager.
@property (nonatomic , strong) NSFileManager *fileManger;

@end

@implementation BKPlayerCachePath


- (NSString *)incompleterVideoWithName:(NSString *)videoName {
    
    if ([self.fileManger fileExistsAtPath:[self videoPathWithFullFile:videoName]]) {
        return [[self videoPathWithFullFile] stringByAppendingPathComponent:videoName];
    }
    return nil;
}

- (NSString *)videoPathWithFullFile:(NSString *)fileName {
    return [[self videoPathWithFullFile] stringByAppendingPathComponent:fileName];
}

- (NSString *)videoPathWithTemporaryFile:(NSString *)fileName {
    return [[self videoPathWithTemporaryFile] stringByAppendingPathComponent:fileName];
}

- (BOOL)creatFileAtTempPath:(NSString *)filePath {
    
    if (!filePath || filePath.length == 0) {
        return NO;
    }
    if ([self.fileManger fileExistsAtPath:filePath]) {
        [self.fileManger removeItemAtPath:filePath error:nil];
    }
    BOOL success = [self.fileManger createFileAtPath:filePath contents:nil attributes:nil];
    return success;
}

- (BOOL)existIncompleteVideo:(NSString *)fileName {
    
    NSString *filePath = [self incompleterVideoWithName:fileName];
    if ([self.fileManger fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

- (BOOL)removeFile:(NSString *)fileName isTempFile:(BOOL)isTempFile {
    
    if (!fileName) {
        return NO;
    }
    NSString *filePath;
    if (isTempFile) {
        filePath = [[self videoPathWithTemporaryFile] stringByAppendingPathComponent:fileName];
    } else {
        filePath = [[self videoPathWithFullFile] stringByAppendingPathComponent:fileName];
        
    }
    BOOL isSuccess = NO;
    if (filePath) {
       isSuccess = [self.fileManger removeItemAtPath:filePath error:nil];
    }
    return isSuccess;
}

- (BOOL)moveTempFileToIncompleteFileWithFileName:(NSString *)fileName {
    
    NSString *tempFilePath = [self videoPathWithTemporaryFile:fileName];
    NSString *destFilePath = [self videoPathWithFullFile:fileName];
    BOOL isSuccess = NO;
    if ([self.fileManger fileExistsAtPath:tempFilePath]) {
        NSError *error;
        isSuccess = [self.fileManger moveItemAtPath:tempFilePath toPath:destFilePath error:&error];
        if (error) {
            NSLog(@"Move File Failed with error :%@" , [error description]);
        }
    }
    
    return isSuccess;
}

- (BOOL)copyTempVideoFileToIncompleteFileWithFileName:(NSString *)fileName {
 
    NSString *tempFilePath = [self videoPathWithTemporaryFile:fileName];
    NSString *destFilePath = [self videoPathWithFullFile:fileName];
    BOOL isSuccess = NO;
    if ([self.fileManger fileExistsAtPath:tempFilePath]) {
        NSError *error;
        isSuccess = [self.fileManger copyItemAtPath:tempFilePath toPath:destFilePath error:&error];
        if (error) {
            NSLog(@"Move File Failed with error :%@" , [error description]);
        }
    }
    return isSuccess;
}

// 完整视频的缓存路径
- (NSString *)videoPathWithFullFile {
    
    NSString *incompletePath = [kDocumentPath stringByAppendingString:BKVideoCacheForIncompleteFile];
    BOOL exist = [self.fileManger fileExistsAtPath:incompletePath isDirectory:NULL];
    if (!exist) {
        [self.fileManger createDirectoryAtPath:incompletePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return incompletePath;
}

// 临时缓存视频路径
- (NSString *)videoPathWithTemporaryFile {
    
    NSString *tempFilePath = [kDocumentPath stringByAppendingString:BKVideoCacheForTemporaryFile];
    BOOL pathExist = [self.fileManger fileExistsAtPath:tempFilePath isDirectory:NULL];
    if (!pathExist) {
        [self.fileManger createDirectoryAtPath:tempFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return tempFilePath;
}

- (NSFileManager *)fileManger {
    
    if (!_fileManger) {
        _fileManger = [NSFileManager defaultManager];
    }
    return _fileManger;
}

@end
