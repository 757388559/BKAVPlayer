//
//  VideoViewController.m
//  BKAVPlayer
//
//  Created by liugangyi on 2017/3/21.
//  Copyright © 2017年 liugangyi. All rights reserved.
//

#import "VideoViewController.h"
#import "BKPlayer.h"

@interface VideoViewController ()
/// player.
@property (nonatomic, strong) BKPlayer *player;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.player = [[BKPlayer alloc] init];
    self.player.normalFrame = CGRectMake(0, 150, self.view.bounds.size.width, 200);
    
    [self.player playWithUrl:[NSURL URLWithString:self.videoUrlStr] isCache:YES];
    [self.view addSubview:self.player];
    self.player.backgroundColor = [UIColor orangeColor];
    
}

- (void)dealloc {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.player];
}

@end
