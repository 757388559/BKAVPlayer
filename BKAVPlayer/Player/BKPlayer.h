//
//  BKPlayer.h
//  BKAVPlayer
//
//  Created by liugangyi on 2016/2/22.
//  Copyright © 2016年 liugangyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BKPlayerControlView.h"

typedef enum : NSUInteger {
    BKPlayerStatusReadyToPlay = 1,
    BKPlayerStatusBuffering = 2,
    BKPlayerStatusPlaying = 3,
    BKPlayerStatusFailed = 4,
    BKPlayerStatusPause = 5,
    BKPlayerStatusStop = 6,
} BKPlayerStatus;

typedef void(^GoBackBlock)(void);

@interface BKPlayer : UIView

/// NormalFrame.
@property (nonatomic, assign) CGRect normalFrame;
/// status.
@property (nonatomic , assign) BKPlayerStatus playerStatus;
/// close block.
@property (nonatomic , copy) GoBackBlock goBackBlock;
/// Current item.
@property (nonatomic, strong , readonly) AVPlayerItem *bkPlayerItem;

- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;

- (void)play;
- (void)pause;
- (void)replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item;

@end

