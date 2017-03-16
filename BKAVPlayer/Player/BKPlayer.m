//
//  BKPlayer.m
//  ZZLAVPlayer
//
//  Created by liugangyi on 2016/2/22.
//  Copyright © 2016年 liugangyi. All rights reserved.
//

#import "BKPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

typedef enum : NSUInteger {
    PanDirectionVerticalMoved,
    PanDirectionHorizontalMoved,
} PanDirection;

static const CGFloat kAnimationTimeOfCtrView = .3;
static const CGFloat kCtrViewShowedTime = 7;

@interface BKPlayer ()

/// Volume.
@property (nonatomic , strong) UISlider *volumeViewSlider;
/// PeriodicTime.
@property (nonatomic , strong) id<NSObject> timeObservation;
/// paused by user.
@property (nonatomic , assign) BOOL isUserPaused;
/// is enter bg.
@property (nonatomic , assign) BOOL didEnterBackground;
/// show ctr View.
@property (nonatomic , assign) BOOL showCtrView;
/// duration.
@property (nonatomic , assign) CGFloat totalDuration;
/// panDirection.
@property (nonatomic , assign) PanDirection panDirection;
/// touch Point.
@property (nonatomic , assign) CGPoint beganPoint;
/// 菊花.
@property (nonatomic , strong) UIActivityIndicatorView *indicatorView;
/// video nature size.
@property (nonatomic , assign) CGSize natureSize;

@end

@implementation BKPlayer


- (instancetype)init {
    self = [super init];
    if (self) {
        [self addNotifications];
        [self setPlayerCtrViewAction];
        [self fadeInCtrView];
    }
    return self;
}

#pragma mark - 通知和观察者方法的实现

- (void)sigleTapForView:(UIGestureRecognizer *)sender {
    if (self.showCtrView) {
        [self fadeOutCtrView];
    } else {
        [self fadeInCtrView];
    }
}

- (void)doubleTapForView:(UIGestureRecognizer *)sender {
    
}


/**
 平移手势控制快进快退和音量亮度
 */
- (void)panGestureForView:(UIPanGestureRecognizer *)sender {
    
    // 速率point-->判定 水平移动 垂直移动
    CGPoint velocityPoint = [sender velocityInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            // 水平移动
            if (x > y) {
                self.beganPoint = [sender locationInView:self];
                self.panDirection = PanDirectionHorizontalMoved;
                [self pause];
            } else if (x < y) {
                // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.panDirection == PanDirectionHorizontalMoved) {
                // 水平 快退快进
                [self horizontalMovedPoint:velocityPoint];
            } else if (self.panDirection == PanDirectionVerticalMoved) {
                // 垂直 声音
                [self panVerticalMovedVelocityPoint:velocityPoint];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.panDirection == PanDirectionHorizontalMoved) {
                
                CMTime slideTime =CMTimeMake(self.totalDuration * self.controlView.sliderTime.value, 1);
                [self.player seekToTime:slideTime completionHandler:^(BOOL finished) {
                    [self play];
                }];
            }
        }
            break;
        default:
            break;
    }
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    if (self.isFullScreen) {
        [self forceChangeOrigentation:UIInterfaceOrientationPortrait];
    }
    [self pause];
}

- (void)deviceOrientationDidChanged {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            self.frame = self.normalFrame;
            self.controlView.btnGoBack.hidden = YES;
            self.isFullScreen = NO;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
//            self.frame = CGRectMake(0, 0, PHONE_WIDTH, PHONE_HEIGH);
            self.controlView.btnGoBack.hidden = NO;
            self.isFullScreen = YES;
        }
            break;
        default:
            break;
    }
}


/**
 插拔耳机
 */
- (void)audioRouteChangeListenerCallback:(NSNotification *)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
//            [self play];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

- (void)applicationDidBecomeActived {
    
    self.didEnterBackground = NO;
}

- (void)applicationDidEnterBackground {
    
    [self.player pause];
    self.didEnterBackground = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
        if ([keyPath isEqualToString:@"player.currentItem.status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                // 平移手势 快进后退
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureForView:)];
                [self addGestureRecognizer:panGesture];
                self.playerStatus = BKPlayerStatusReadyToPlay;
                self.totalDuration = CMTimeGetSeconds(self.player.currentItem.duration);
                self.controlView.labRemainTime.text = [self fomatTimeStr:self.totalDuration];
                self.controlView.btnPlay.userInteractionEnabled = self.controlView.sliderTime.userInteractionEnabled = YES;
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.playerStatus = BKPlayerStatusFailed;
            }
        } else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
            // 设置缓冲值
            NSTimeInterval timeCache = [self availableCacheDuration];
            CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
            [self.controlView.progressView setProgress:timeCache/totalTime animated:NO];
            // 如果缓冲的和当期的播放slider差值为0.1，自动播放(以防弱网情况下不会自动播放)
            if (!self.isUserPaused && !self.didEnterBackground && (self.controlView.progressView.progress-self.controlView.sliderTime.value > 0.05)) {
                [self play];
            }
        } else if ([keyPath isEqualToString:@"player.currentItem.playbackBufferEmpty"]) {
            // 缓冲是空的时候
            if (self.player.currentItem.playbackBufferEmpty) {
                self.playerStatus = BKPlayerStatusBuffering;
                if (![self.indicatorView isAnimating]) {
                    [self.indicatorView startAnimating];
                    self.indicatorView.hidden = NO;
                }
            }
            
        } else if ([keyPath isEqualToString:@"player.currentItem.playbackLikelyToKeepUp"]) {
            // 缓冲好的时候
            if (self.player.currentItem.playbackLikelyToKeepUp) {
                self.playerStatus = BKPlayerStatusReadyToPlay;
                [self.indicatorView stopAnimating];
            }
        }

}

#pragma mark - 通知、观察者和手势的添加

- (void)addObservesForPlayerItem {
    
    // 播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    // item 当前状态
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲了多长时间
    [self addObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，需要等待数据
    [self addObserver:self forKeyPath:@"player.currentItem.playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区有足够数据可以播放了
    [self addObserver:self forKeyPath:@"player.currentItem.playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    // 实时播放时间
//    WS(weakSelf);
    self.timeObservation = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat currentTime = CMTimeGetSeconds(time);
        // 设置播放时间
//        weakSelf.controlView.labCurrentTime.text = [weakSelf fomatTimeStr:currentTime];
        // 设置剩余时间
//        weakSelf.controlView.labRemainTime.text = [weakSelf fomatTimeStr:(weakSelf.totalDuration - currentTime)];
        // 设置时间滑竿的值
//        [weakSelf.controlView.sliderTime setValue:currentTime/weakSelf.totalDuration animated:NO];
    }];
}

- (void)addNotifications {
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // 设备旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    // 进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActived) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 单击 手势
    UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapForView:)];
    [self addGestureRecognizer:sigleTap];
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapForView:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)setPlayerCtrViewAction {
    
    [self.controlView.btnGoBack addTarget:self action:@selector(controlViewActions:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.btnPlay addTarget:self action:@selector(controlViewActions:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.btnFullScreen addTarget:self action:@selector(controlViewActions:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.sliderTime addTarget:self action:@selector(touchDownTimeSlider:) forControlEvents:UIControlEventTouchDown];
    [self.controlView.sliderTime addTarget:self action:@selector(slideTimeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.controlView.sliderTime addTarget:self action:@selector(touchCancelTimeSlider:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    self.controlView.btnGoBack.tag = 1000;
    self.controlView.btnPlay.tag = 1001;
    self.controlView.btnFullScreen.tag = 1002;
}

#pragma mark - controlView 方法回调

- (void)controlViewActions:(UIControl *)sender {
    
    switch (sender.tag) {
        case 1000:
        {
            // 返回按钮
            if (self.goBackBlock) {
                [self forceChangeOrigentation:UIInterfaceOrientationPortrait];
                self.goBackBlock();
            }
        }
            break;
        case 1001:
        {
            // 播放/暂停
            self.controlView.btnPlay.selected = !sender.selected;
            self.isUserPaused = !sender.selected;
            if (sender.selected) {
                [self play];
                if (self.playerStatus == BKPlayerStatusPause)
                    self.playerStatus = BKPlayerStatusPlaying;
            } else {
                [self pause];
                if (self.playerStatus == BKPlayerStatusPlaying)
                    self.playerStatus = BKPlayerStatusPause;
            }
            
        }
            break;
        case 1002:
        {
            // 全屏小屏按钮
            self.controlView.btnFullScreen.selected = !sender.selected;
            if (sender.selected) {
                [self forceChangeOrigentation:UIInterfaceOrientationLandscapeLeft];
            } else {
                [self forceChangeOrigentation:UIInterfaceOrientationPortrait];
            }
            
        }
            break;
        default:
            break;
    }
    
}


#pragma mark - 辅助 

- (void)play {
    
    [self.indicatorView stopAnimating];
    self.controlView.btnPlay.selected = YES;
    [self.player play];
}

- (void)pause {
    
    self.controlView.btnPlay.selected = NO;
    [self.player pause];
}


/**
 强制切换屏幕
 */
- (void)forceChangeOrigentation:(UIInterfaceOrientation)orientation {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/**
 计算缓冲区域
 */
- (NSTimeInterval)availableCacheDuration {
    NSArray *loadedTimeRanges = [self.player.currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


/**
 格式化时间字符串 播放时间转化
 */
- (NSString *)fomatTimeStr:(CGFloat)time {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}


/**
 获取系统音量
 */
- (void)configureVolume {
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    if (!success) { /* handle the error in setCategoryError */ }
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}


/**
 控制条淡出
 */
- (void)fadeOutCtrView {
    
    if (self.showCtrView == NO) {
        return;
    }
    [UIView animateWithDuration:kAnimationTimeOfCtrView animations:^{
        self.controlView.bottomCtrView.alpha = 0;
        self.controlView.topCtrView.alpha = 0;
    } completion:^(BOOL finished) {
        self.showCtrView = NO;
    }];
}


/**
 控制条渐显
 */
- (void)fadeInCtrView {
    
    if (self.showCtrView) {
        return;
    }
    [UIView animateWithDuration:kAnimationTimeOfCtrView animations:^{
        if (self.isFullScreen) {
            self.controlView.bottomCtrView.alpha = 1;
            self.controlView.topCtrView.alpha = 1;
        } else {
            self.controlView.topCtrView.alpha = 0;
            self.controlView.bottomCtrView.alpha = 1;
        }
    } completion:^(BOOL finished) {
        self.showCtrView = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutCtrView) object:nil];
        [self performSelector:@selector(fadeOutCtrView) withObject:nil afterDelay:kCtrViewShowedTime];
    }];
}


/**
 水平移动的方法
 */
- (void)horizontalMovedPoint:(CGPoint)currentPoint {

    // 移动的值-触摸点的值 = 移动的距离
    //CGFloat dragLongth = currentPoint.x - self.beganPoint.x;
    // 移动距离占的百分比
    //CGFloat percent = dragLongth / PHONE_WIDTH * .01;
    // 当前时间条的进度
    CGFloat value = self.controlView.sliderTime.value;
    if (currentPoint.x > 0) {
        value += .01;
    } else {
        value -= .01;
    }
    [self.controlView.sliderTime setValue:value animated:NO];
}


/**
 垂直移动
 */
- (void)panVerticalMovedVelocityPoint:(CGPoint)velocityPoint {
    
    self.volumeViewSlider.value -= velocityPoint.y / 10000;
}

#pragma mark - 滑动时间进度

/**
 开始滑动时间进度
 */
- (void)touchDownTimeSlider:(UISlider *)slider {
    [self pause];
}

/**
 滑动中
 */
- (void)slideTimeSlider:(UISlider *)slider {
    
}

/**
 滑动结束
 */
- (void)touchCancelTimeSlider:(UISlider *)slider {
    
    // 滑块的当前值
    CGFloat value = slider.value;
    // 把滑块的当前值换算为时间
    CGFloat valueTime = value * self.totalDuration;
    // 播放器跳到那个值
    [self.player seekToTime:CMTimeMake(valueTime, 1) completionHandler:^(BOOL finished) {
        [self play];
    }];
}

#pragma mark - setter and getter

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    
    if (self.player.currentItem != playerItem) {
        _playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (BKPlayerControlView *)controlView {
    
    if (!_controlView) {
        _controlView = [[BKPlayerControlView alloc] init];
        _controlView.btnGoBack.hidden = YES;
        _controlView.topCtrView.alpha = 0;
        _controlView.sliderTime.userInteractionEnabled = NO;
        _controlView.btnPlay.userInteractionEnabled = NO;
        [self addSubview:_controlView];
//        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.top.bottom.equalTo(self);
//        }];
    }
    return _controlView;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    
    if (isFullScreen != self.isFullScreen) {
        _isFullScreen = isFullScreen;
        if (isFullScreen)
            self.controlView.btnFullScreen.selected = isFullScreen;
        else
            self.controlView.btnFullScreen.selected = isFullScreen;
    }
}

- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_indicatorView];
//        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(0);
//        }];
    }
    return _indicatorView;
}

#pragma mark - Class layer

// Over ridde
+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self playerLayer] setPlayer:player];
    [self addObservesForPlayerItem];
    [self configureVolume];
    [self.indicatorView startAnimating];
}

- (AVPlayerLayer *)playerLayer{
    AVPlayerLayer *currtentLayer = (AVPlayerLayer *)self.layer;
    currtentLayer.videoGravity = AVLayerVideoGravityResize;
    return currtentLayer;
}

- (void)dealloc {
    
    
    [self.player removeTimeObserver:_timeObservation];
    _timeObservation = nil;
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [self removeObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges"];
    [self removeObserver:self forKeyPath:@"player.currentItem.playbackBufferEmpty"];
    [self removeObserver:self forKeyPath:@"player.currentItem.playbackLikelyToKeepUp"];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    debugLog(@"%@ 播放器释放了" , self.class);
}

@end
