//
//  LyricManager.h
//  音乐播放器
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 C. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricManager : NSObject
// 单例
+ (instancetype)shareLyricManager;
// 接口
- (void)loadLyricWith:(NSString *)lyricStr;
// 对外的歌词数组
@property (nonatomic,strong) NSArray *allLyric;

/**
 *  根据播放时间获取到该播放歌词的索引
 */
- (NSInteger)indexWith:(NSTimeInterval)time;


@end
