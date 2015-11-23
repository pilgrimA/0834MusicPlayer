//
//  PlayingViewController.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 C. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "DataManager.h"
#import "LyricModel.h"

@interface PlayingViewController ()<PlayerManagerDelegate,UITableViewDelegate,UITableViewDataSource>

// 记录一下当前的音乐的索引
@property (nonatomic,assign) NSInteger currentIndex;
// 记住当前正在播放的音乐
@property (nonatomic,retain) MusicModel *currentModel;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLyric;

#pragma mark 控件
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *singerName;
@property (weak, nonatomic) IBOutlet UIImageView *imgPic;
@property (weak, nonatomic) IBOutlet UILabel *playedTime;
@property (weak, nonatomic) IBOutlet UILabel *lastTime;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

@property (weak, nonatomic) IBOutlet UIButton *volumeBtn;

@property (weak, nonatomic) IBOutlet UIImageView *tableImgView;

@end


@implementation PlayingViewController

static PlayingViewController *playingVC=nil;
// 重用标识符
static NSString *identifier=@"cell";

#pragma mark 控件事件
- (IBAction)prevAction:(UIButton *)sender {
    _currentIndex--;
    // 判断是否是第一首
    if (_currentIndex==-1) {
        // 如果是第一首，就播放最后一首
        _currentIndex=[DataManager shareDataManager].musicArray.count-1;
    }
    [self startPlay];
}

// 暂停或者播放事件
- (IBAction)playOrPauseAction:(UIButton *)sender {
    // 判断是否正在播放
    if ([PlayerManager shareManager].isPlaying) {
        // 如果正在播放，就让播放器暂停，同时改变button的text
        [[PlayerManager shareManager] pause];
        [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }else{
        // 暂停状态：开始播放，并改变btn为暂停
        [[PlayerManager shareManager] play];
        [sender setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    }
}

// 下一首
- (IBAction)nextAction:(UIButton *)sender {
    _currentIndex++;
    // 判断是否是最后一首
    if (_currentIndex==[DataManager shareDataManager].musicArray.count) {
        //如果是最后一首，就播放第一首
        _currentIndex=0;
    }
    [self startPlay];
}

// 改变播放的进度
- (IBAction)changeTime:(UISlider *)sender {
    // 调用接口
    [[PlayerManager shareManager] seekToTime:sender.value];
}
// 改变音量
- (IBAction)changeVolume:(UISlider *)sender {
    [[PlayerManager shareManager] playerVolume:sender.value];
}

+ (instancetype)sharedPlayingPVC{
    // 多线程
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 创建Storyboard
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // 取出需求的ViewController--在main中拿到我们需求的视图控制器
        playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
        
    });
    return playingVC;
}

- (void)startPlay{
    // 播放音乐
    [[PlayerManager shareManager] playWithUrlString:self.currentModel.mp3Url];
    
    [self buildUI];
}

// 加载UI
- (void)buildUI{
    // self.才会走get方法(才会显示在label上)
    self.singerName.text=self.currentModel.singer;
    self.songName.text=self.currentModel.name;
    
    // 显示图片
    [self.imgPic sd_setImageWithURL:[NSURL URLWithString:self.currentModel.picUrl]];
    // 加载tableView背景图片
    [self.tableImgView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.blurPicUrl]];
    // 更改button
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
    
    // 改变进度条的最大值
    self.timeSlider.maximumValue=[self.currentModel.duration intValue]/1000;
    self.timeSlider.value=0;
    
    // 更改旋转角度,图片归位
    self.imgPic.transform=CGAffineTransformMakeRotation(0);
    
    //显示歌词
    [[LyricManager shareLyricManager]loadLyricWith:self.currentModel.lyric];
    //刷新数据
    [self.tableViewLyric reloadData];
    // volumeSlider初始隐藏
    self.volumeSlider.hidden=YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 如果要播放的音乐当前播放的音乐一样，就什么都不干了
    if (_index==_currentIndex) {
        return;
    }
    // 如果不等于,给当前播放的音乐索引赋值
    _currentIndex=_index;
    // 开始播放
    [self startPlay];
}

// 只运行一次
- (void)viewDidLoad {
    [super viewDidLoad];
    // 给定一个初始值
    _currentIndex=-1;
    // 切圆角
    self.imgPic.layer.masksToBounds=YES;
    self.imgPic.layer.cornerRadius=120;
    
    // 设置自己为播放器的代理，帮播放器干一些事情
    [PlayerManager shareManager].delegate=self;
    // 设置音量默认值
    self.volumeSlider.value=[[PlayerManager shareManager] volume];
    
    // 注册cell
    [self.tableViewLyric registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    //volumeBtn
    [self.volumeBtn setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    // 点击事件
    [self.volumeBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    // volumeSlider
    self.volumeSlider.transform=CGAffineTransformMakeRotation(M_PI_2*3);
    
}

// 点击事件volumeSlider显示,改变其显隐性
- (void)click:(UIButton *)sneder{
    if (self.volumeSlider.hidden) {
        self.volumeSlider.hidden=NO;
    }else{
        self.volumeSlider.hidden=YES;
    }
    
}

// 取消volumenSlider的显示
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.volumeSlider.hidden=YES;
}
// volumeSlider值改变变化时，改变btn的图片显示
- (IBAction)changeVolumeSlider:(UISlider *)sender {
    if (_volumeSlider.value==0) {
        [self.volumeBtn setImage:[UIImage imageNamed:@"2"] forState:UIControlStateNormal];
    }else{
        [self.volumeBtn setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(UIButton *)sender {
    // 返回界面
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark--PlayerManagerDelegate
// 播放器播放结束了，开始播放下一首
-(void)playerDidPlayEnd{
    [self nextAction:nil];
}

// 播放器每0.1秒回让代理（也就是这个页面）执行一下这个事件
- (void)playerPlayingWithTime:(NSTimeInterval)time{
    // 时间slider的进度实时显示
    self.timeSlider.value=time;
    // 显示播放时间
    self.playedTime.text=[self stringWithTime:time];
    // 计算剩余时间
    NSTimeInterval time2=[self.currentModel.duration intValue]/1000-time;
    // 显示剩余时间
    self.lastTime.text=[self stringWithTime:time2];
    // 每0.1秒转一度
    self.imgPic.transform=CGAffineTransformRotate(self.imgPic.transform, M_PI/180);
    // 根据当前播放时间获取到应该播放哪句歌词
    NSInteger index=[[LyricManager shareLyricManager] indexWith:time];
    NSIndexPath *path=[NSIndexPath indexPathForRow:index inSection:0];
    // 让tableView选中我们要找到的歌词
    [self.tableViewLyric selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

// 根据时间获取字符串
- (NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes=time/60;
    NSInteger seconds=(int)time%60;
    return [NSString stringWithFormat:@"%ld:%ld",minutes,seconds];
}

#pragma mark getter
// 确保当前播放的音乐是最新的
-(MusicModel *)currentModel{
    // 取到要播放的model(因为要做上一首，下一首，所以要用currentIndex)
    MusicModel *model = [[DataManager shareDataManager] musicModelWithIndex:self.currentIndex];
    return model;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LyricManager shareLyricManager].allLyric.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    // cell显示内容
//    cell.textLabel.text=@"歌词";
    // 歌词居中
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    // model
    LyricModel *lyric=[LyricManager shareLyricManager].allLyric[indexPath.row];
    // 设置歌词
    cell.textLabel.text=lyric.lyricContext;
//    cell.textLabel.font=[UIFont systemFontOfSize:10];
    // 设置cell背景颜色
    cell.backgroundColor=[UIColor clearColor];
    
    // 设置文字颜色
//    cell.textLabel.textColor=[UIColor redColor];
    // 选中cell的文本颜色
    cell.textLabel.highlightedTextColor=[UIColor orangeColor];
    return cell;
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
