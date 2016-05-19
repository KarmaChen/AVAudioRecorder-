//
//  ViewController.m
//  AVAudioRecorder录音
//
//  Created by Karma on 16/5/19.
//  Copyright © 2016年 陈昆涛. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVAudioPlayerDelegate>
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet UIButton *longPressBtn;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToRec:)];
    [self.longPressBtn addGestureRecognizer:longPressGesture];
    
}

-(NSURL *)url{
    if (_url == nil) {
        //从沙盒中取出一个路径
        NSString *tmpDir = NSTemporaryDirectory();
        //再在路径中新建record.caf用于记录录音
        NSString *urlPath = [tmpDir stringByAppendingString:@"record.caf"];
        //实例化URL的对象
        _url = [NSURL fileURLWithPath:urlPath];
    }
    return _url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startRecord:(id)sender {

    }
-(void) startRecord {
        NSError *error = nil;
        
        //激活AVAudioSession
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (session != nil) {
            [session setActive:YES error:nil];
        }else {
            NSLog(@"session error: %@",error);
        }
        
        //设置AVAudioRecorder类的setting参数
        NSDictionary *recorderSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:16000.0],AVSampleRateKey,
                                          [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                          [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                          [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                          nil];
        
        //实例化AVAudioRecorder对象
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.url settings:recorderSettings error:&error];
        if (error) {
            NSLog(@"recorder error: %@", error);
        }
        
        //开始录音
        [self.recorder prepareToRecord];
        [self.recorder record];
    }
-(void) endRecord {
    [self.recorder stop];
    self.recorder = nil;
}


//停止录音
- (IBAction)stopRecord:(id)sender {
    [self.recorder stop];
    //释放self.recorder,否则无法更新录音文件，即不能进行二次录音
    self.recorder = nil;

}
//播放录音

//创建AVAudioPlayer对象
-(AVAudioPlayer *)player{
    if (_player == nil) {
        NSError *error = nil;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:&error];
        _player.volume = 1.0;
        
        _player.delegate = self;
        
        if (error) {
            NSLog(@"player error:%@",error);
        }
    }
    return _player;
}
//播放录音，并设置播放输出源：耳机、外放
- (IBAction)playRecord:(id)sender {
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (audioRouteOverride),&audioRouteOverride);
    
    [self.player play];

}
#pragma mark -AVAudioPlayer代理方法
//销毁AVAudioPlayer对象
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"%s",__func__);
    self.player = nil;
}
-(void) longPressToRec:(UILongPressGestureRecognizer *) sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        //开始录音
        [self startRecord];
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        //结束录音
        [self endRecord];
    }
}
@end
