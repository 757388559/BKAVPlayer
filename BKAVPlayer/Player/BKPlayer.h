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


typedef void(^GoBackBlock)(void);

typedef enum : NSUInteger {
    BKPlayerStatusReadyToPlay = 0,
    BKPlayerStatusBuffering = 1,
    BKPlayerStatusPlaying = 2,
    BKPlayerStatusFailed = 3,
    BKPlayerStatusPause = 4,
    BKPlayerStatusStop = 5,
} BKPlayerStatus;


@interface BKPlayer : UIView

/// player.
@property(nonatomic) AVPlayer *player;
/// current playerLayer.
@property(nonatomic, readonly) AVPlayerLayer *playerLayer;
/// current item.
@property (nonatomic, strong) AVPlayerItem *playerItem;
/// normalFrame.
@property (nonatomic, assign) CGRect normalFrame;
/// is full screen.
@property (nonatomic , assign) BOOL isFullScreen;
/// control View.
@property (nonatomic , strong) BKPlayerControlView *controlView;
/// status.
@property (nonatomic , assign) BKPlayerStatus playerStatus;
/// close block.
@property (nonatomic , copy) GoBackBlock goBackBlock;

@end

