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

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    BKPlayer *player = [[BKPlayer alloc] init];
    player.normalFrame = CGRectMake(0, 150, self.view.bounds.size.width, 200);
    NSURL *url = [NSURL URLWithString:self.videoUrlStr];
    
    [player playWithUrl:url];
    [self.view addSubview:player];
    player.backgroundColor = [UIColor orangeColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
