//
//  LyricManager.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 C. All rights reserved.
//

#import "LyricManager.h"
#import "LyricModel.h"

@interface LyricManager ()

// 装model的数组,用来存放歌词
@property (nonatomic,strong) NSMutableArray *lyrics;

@end

static LyricManager *manager=nil;

@implementation LyricManager

+ (instancetype)shareLyricManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[LyricManager new];
        
    });
    return manager;
}

//[00:00.00] 作曲 : Wiz Khalifa
//[00:01.00] 作词 : Wiz Khalifa
//[00:10.440]It's been a long day without you my friend
//[00:17.400]And I'll tell you all about it when I see you again
- (void)loadLyricWith:(NSString *)lyricStr{
    // 移除前一首歌词
    [self.lyrics removeAllObjects];
    // 判断是否有歌词
    if ([lyricStr isEqual:@""]) {
        LyricModel *model=[[LyricModel alloc] initWithTime:0 lyric:@"暂无歌词"];
        [self.lyrics addObject:model];
        return;
    }
    // 1.分行
    NSArray *lyricStringArray=[lyricStr componentsSeparatedByString:@"\n"];
    for (NSString *str in lyricStringArray) {
//        NSLog(@"%@",str);
        // 截取的时候最后一行为空(@"")，需要判断
        if ([str isEqualToString:@""]) {
            return;
        }
        // 2.分开时间和歌词
        NSArray *timeAndLyric=[str componentsSeparatedByString:@"]"];
        // 有的数据只有部分数据
        if (timeAndLyric.count!=2) {
            // 跳出for循环
            continue;
        }
        // 3.去掉时间左边的“[”
        NSString *time=[timeAndLyric[0] substringFromIndex:1];
        // time=00:10.440
        // 4.截取时间，获取分和秒
        NSArray *minuteAndSecond=[time componentsSeparatedByString:@":"];
        // 分
        NSInteger minute=[minuteAndSecond[0] integerValue];
        // 秒
        double second=[minuteAndSecond[1] doubleValue];
        
        // 创建一个model，封装分和秒
        LyricModel *model=[[LyricModel alloc] initWithTime:(minute * 60 +second) lyric:timeAndLyric[1]];
        // 添加到数组
        [self.lyrics addObject:model];
    }
}

- (NSInteger)indexWith:(NSTimeInterval)time{
    NSInteger index=0;
    // 遍历数组，找到还没有播放的那一句歌词
    for (int i=0; i<self.lyrics.count; i++) {
        LyricModel *model=self.lyrics[i];
        if (model.time>time) {
             // 注意如果是零个元素，而且元素的时间比要播放的时间大，i-1，就会小于0.这样tableview就会crash
            index=(i-1>0)?i-1:0;
            // 找到就返回,否则，就会一直循环
            break;
        }
    }
    return index;
}

// lazy load
-(NSMutableArray *)lyrics{
    if (!_lyrics) {
        _lyrics=[NSMutableArray new];
    }
    return _lyrics;
}

// get
-(NSArray *)allLyric{
    return self.lyrics;
}

@end
