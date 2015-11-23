//
//  PlayerManager.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 C. All rights reserved.
//

#import "PlayerManager.h"
#import "AVFoundation/AVFoundation.h"

// 声明属性
@interface PlayerManager()
// 播放器--全局唯一,单例---如果有两个player的话，就会同时播放两个音乐
@property (nonatomic,strong) AVPlayer *player;
// 播放时间
@property (nonatomic,retain) NSTimer *timer;

@end

@implementation PlayerManager

static PlayerManager *manager=nil;
//单例方法
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[PlayerManager new];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        // 添加通知中心，当self发出AVPlayerItemDidPlayToEndTimeNotification时触发PlayerDidPlayEnd事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)PlayerDidPlayEnd:(NSNotification *)sender{
    // 判断代理是否走了这个方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)]) {
        // 接受到item播放结束后，让代理去干一些事情，代理会怎么干，播放器不需要知道
        [self.delegate playerDidPlayEnd];
        // GDNotification
        [JDStatusBarNotification showWithStatus:@"下一首" dismissAfter:2 styleName:JDStatusBarStyleDefault];
    }
}

#pragma mark 对外方法
- (void)playWithUrlString:(NSString *)urlStr{
    
    if (self.player.currentItem) {
        // 如果是切换歌曲，要先把当前歌曲的观察者移除
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    // 创建一个item
    AVPlayerItem *item=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    
    // 给item添加一个观察者
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 替换当前正在播放的音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    
}

//  play播放
- (void)play{
    // 如果正在播放，就不播放了，直接返回。
//    if (_isPlaying) {
//        return;
//    }
    [self.player play];
    // 开始播放后标记一下
    _isPlaying=YES;
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingWithSeconds) userInfo:nil repeats:YES];
}

// 打印播放时间
- (void)playingWithSeconds{
//    NSLog(@"%lld",self.player.currentTime.value/self.player.currentTime.timescale);
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
        // 计算一下播放器现在播放的秒数
        NSTimeInterval time=self.player.currentTime.value/self.player.currentTime.timescale;
        [self.delegate playerPlayingWithTime:time];
    }
}

//  play暂停
- (void)pause{
    
    [self.player pause];
    // 暂停播放后设为NO
    _isPlaying=NO;
    
    //移除计时器
    [self.timer invalidate];
}

// 改变播放时间进度
- (void)seekToTime:(NSTimeInterval)time{
    // 先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            // 拖拽成功后播放
            [self play];
        }
    }];
}

// 音量
- (void)playerVolume:(float)volume{
    self.player.volume=volume;
}

- (CGFloat)volume{
    return self.player.volume;
}

#pragma mark--lazy load
-(AVPlayer *)player{
    if (!_player) {
        _player=[AVPlayer new];
    }
    return _player;
}

#pragma mark --观察响应
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    NSLog(@"keyPath=%@--change=%@",keyPath,change);
    AVPlayerItemStatus status=[change[@"new"] integerValue];
    
    switch (status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"资源不对");
            break;
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"准备好了，可以播放");
            // 开始播放(资源正确，加载完成才开始播放)
//            [self.player play];
            // 先暂停，将NSTimeer销毁，然后再播放，创建NSTimer
            [self play];
            break;
        default:
            break;
    }
}

@end
