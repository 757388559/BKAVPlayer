//
//  BKPlayerResourceLoader.h
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/20.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Download.h"

//@protocol BKPlayerRquestTaskDelegate <NSObject>
//
//
//@end

@interface BKPlayerResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic , strong) Download *dataDownload;
//@property (nonatomic , weak) id <BKPlayerRquestTaskDelegate> delegate;


@end
