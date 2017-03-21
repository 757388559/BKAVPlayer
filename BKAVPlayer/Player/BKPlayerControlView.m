//
//  BKPlayerControlView.m
//  BKAVPlayer
//
//  Created by liugangyi on 2016/2/22.
//  Copyright © 2016年 liugangyi. All rights reserved.
//



#import "BKPlayerControlView.h"
#import "Masonry.h"

static const CGFloat topCtrViewHeight = 44;
static const CGFloat bottomCtrViewHeight = 44;
static const CGFloat space = 10;
static const CGFloat leftMargin = 15;

@implementation BKPlayerControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self markSubviewsContraints];
    }
    return self;
}

#pragma mark - Public Method

// 淡出/显底部控制条
- (void)fadeInOutBottomCtrView {
    
    if (self.showBottomView) {
        [UIView animateWithDuration:.3 animations:^{
            self.bottomCtrView.alpha = 0;
        } completion:^(BOOL finished) {
            self.showBottomView = NO;
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            self.bottomCtrView.alpha = 1;
        } completion:^(BOOL finished) {
            self.showBottomView = YES;
        }];
    }

}

// 淡出/显顶部控制条
- (void)fadeInOutTopCtrView {
    
    if (self.showTopView) {
        [UIView animateWithDuration:.3 animations:^{
            self.topCtrView.alpha = 0;
        } completion:^(BOOL finished) {
            self.showTopView = NO;
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            self.topCtrView.alpha = 1;
        } completion:^(BOOL finished) {
            self.showTopView = YES;
        }];
    }

}

- (void)resetCtrViewBoolValueIsHide {
    
    self.showTopView = NO;
    self.showBottomView = NO;
}

#pragma mark - Mark subviews Constraints

- (void)markSubviewsContraints {
    
    [self.topCtrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.mas_equalTo(0);
        make.height.mas_equalTo(topCtrViewHeight);
    }];
    [self.bottomCtrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.mas_equalTo(0);
        make.height.mas_equalTo(bottomCtrViewHeight);
    }];
    [self.btnGoBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.centerY.mas_equalTo(0);
    }];
    [self.btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(leftMargin);
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(44);
        make.centerY.mas_equalTo(0);
    }];
    [self.labCurrentTime mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.btnPlay.mas_right).offset(space);
        make.left.equalTo(self.btnPlay.mas_right);
        make.centerY.mas_equalTo(0);
    }];
    [self.btnFullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-leftMargin);
        make.right.mas_equalTo(0);
        make.width.height.mas_equalTo(44);
        make.centerY.mas_equalTo(0);
    }];
    [self.labRemainTime mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.btnFullScreen.mas_left).offset(-space);
        make.right.equalTo(self.btnFullScreen.mas_left);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.sliderTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labCurrentTime.mas_right).offset(space);
        make.right.equalTo(self.labRemainTime.mas_left).offset(-space);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderTime.mas_left);
        make.right.equalTo(self.sliderTime.mas_right);
        make.centerY.equalTo(self.sliderTime.mas_centerY);
    }];
    [self.bottomCtrView bringSubviewToFront:self.sliderTime];
}

#pragma mark - setter and getter

- (UIView *)topCtrView {
    
    if (!_topCtrView) {
        _topCtrView = [[UIView alloc] init];
        _topCtrView.backgroundColor = kRGBAColor(0, 0, 0, .95);
        [self addSubview:_topCtrView];
    }
    return _topCtrView;
}

- (UIView *)bottomCtrView {
    
    if (!_bottomCtrView) {
        _bottomCtrView = [[UIView alloc] init];
//        _bottomCtrView.backgroundColor = kRGBAColor(0, 0, 0, .95);
        _bottomCtrView.backgroundColor = [UIColor grayColor];
        [self addSubview:_bottomCtrView];
    }
    return _bottomCtrView;
}

- (UIButton *)btnPlay {
    
    if (!_btnPlay) {
        _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPlay setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        [_btnPlay setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateSelected];
        [self.bottomCtrView addSubview:_btnPlay];
    }
    return _btnPlay;
}

- (UIButton *)btnGoBack {
    
    if (!_btnGoBack) {
        _btnGoBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnGoBack setTitle:@"关闭" forState:UIControlStateNormal];
        _btnGoBack.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnGoBack setTitleColor:kRGBColor(255, 255, 255) forState:UIControlStateNormal];
        [self.topCtrView addSubview:_btnGoBack];
    }
    return _btnGoBack;
}

- (UIButton *)btnFullScreen {
    
    if (!_btnFullScreen) {
        _btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFullScreen setImage:[UIImage imageNamed:@"video_normalScreen"] forState:UIControlStateNormal];
        [_btnFullScreen setImage:[UIImage imageNamed:@"video_fullScreen"] forState:UIControlStateNormal];
        [self.bottomCtrView addSubview:_btnFullScreen];
    }
    return _btnFullScreen;
}

- (UILabel *)labTitle {
    
    if (!_labTitle) {
        _labTitle = [[UILabel alloc] init];
        [self.topCtrView addSubview:_labTitle];
    }
    return _labTitle;
}

- (UILabel *)labCurrentTime {
    
    if (!_labCurrentTime) {
        _labCurrentTime = [[UILabel alloc] init];
        _labCurrentTime.text = @"00:00";
        _labCurrentTime.textColor = [UIColor whiteColor];
        [self.bottomCtrView addSubview:_labCurrentTime];
    }
    return _labCurrentTime;
}

- (UILabel *)labRemainTime {
    
    if (!_labRemainTime) {
        _labRemainTime = [[UILabel alloc] init];
        _labRemainTime.text = @"00:00";
        _labRemainTime.textColor = [UIColor whiteColor];
        [self.bottomCtrView addSubview:_labRemainTime];
    }
    return _labRemainTime;
}

- (UISlider *)sliderTime {
    
    if (!_sliderTime) {
        _sliderTime = [[UISlider alloc] init];
        [_sliderTime setThumbImage:[UIImage imageNamed:@"video_trunck"] forState:UIControlStateNormal];
        _sliderTime.backgroundColor = [UIColor clearColor];
        _sliderTime.maximumTrackTintColor = [UIColor clearColor];
        _sliderTime.minimumTrackTintColor = [UIColor whiteColor];
        [self.bottomCtrView addSubview:_sliderTime];
    }
    return _sliderTime;
}

- (UIProgressView *)progressView {
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor grayColor];
        _progressView.trackTintColor = [UIColor clearColor];
        [self.bottomCtrView addSubview:_progressView];
    }
    return _progressView;
}

@end
