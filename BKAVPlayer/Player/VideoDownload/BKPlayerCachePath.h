//
//  BKPlayerCachePath.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPlayerCachePath : NSObject

// 获取指定的完整视频的路径
- (NSString *)incompleterVideoWithName:(NSString *)videoName;

- (NSString *)videoPathWithTemporaryFile:(NSString *)fileName;

- (NSString *)videoPathWithFullFile:(NSString *)fileName;

- (BOOL)creatFileAtTempPath:(NSString *)filePath;

- (BOOL)existIncompleteVideo:(NSString *)fileName;

- (BOOL)removeFile:(NSString *)fileName isTempFile:(BOOL )isTempFile;

- (BOOL)moveTempFileToIncompleteFileWithFileName:(NSString *)fileName;

- (BOOL)copyTempVideoFileToIncompleteFileWithFileName:(NSString *)fileName;


@end
