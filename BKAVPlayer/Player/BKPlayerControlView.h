//
//  BKPlayerControlView.h
//  BKAVPlayer
//
//  Created by liugangyi on 2016/2/22.
//  Copyright © 2016年 liugangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKPlayerControlView : UIView

/// play/pause.
@property (nonatomic , strong) UIButton *btnPlay;
/// go back.
@property (nonatomic , strong) UIButton *btnGoBack;
/// title.
@property (nonatomic , strong) UILabel *labTitle;
/// current time.
@property (nonatomic , strong) UILabel *labCurrentTime;
/// remain time.
@property (nonatomic , strong) UILabel *labRemainTime;
/// slider.
@property (nonatomic , strong) UISlider *sliderTime;
/// fullScreen.
@property (nonatomic , strong) UIButton *btnFullScreen;
/// topView.
@property (nonatomic , strong) UIView *topCtrView;
/// bottomview.
@property (nonatomic , strong) UIView *bottomCtrView;
/// cache time.
@property (nonatomic , strong) UIProgressView *progressView;

/// show top ctr View.
@property (nonatomic , assign) BOOL showTopView;
/// show bottom ctr View.
@property (nonatomic , assign) BOOL showBottomView;

/**
 显示顶部控制条
 */
- (void)fadeInOutTopCtrView;

/**
 显示底部控制条
 */
- (void)fadeInOutBottomCtrView;

/**
 重置 CtrView的bool值
 */
- (void)resetCtrViewBoolValueIsHide;

@end
