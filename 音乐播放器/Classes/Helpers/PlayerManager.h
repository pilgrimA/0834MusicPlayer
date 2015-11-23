//
//  PlayerManager.h
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 C. All rights reserved.
//

#import <Foundation/Foundation.h>
// 代理
@protocol PlayerManagerDelegate <NSObject>

//当播放一首歌结束后，让代理去做得事情
- (void)playerDidPlayEnd;
// 播放中间一直在重复执行的一个方法
- (void)playerPlayingWithTime:(NSTimeInterval)time;

@end


@interface PlayerManager : NSObject

// 判断当前是否正在播放
@property (nonatomic,assign) BOOL isPlaying;

+ (instancetype)shareManager;
// 给一个链接，让播放器播放
- (void)playWithUrlString:(NSString *)urlStr;

//  play播放
- (void)play;

//  play暂停
- (void)pause;

// 设置代理
@property (nonatomic,assign) id<PlayerManagerDelegate> delegate;

// 改变进度
- (void)seekToTime:(NSTimeInterval)time;

// 音量
- (void)playerVolume:(float)volume;

- (CGFloat)volume;
@end
