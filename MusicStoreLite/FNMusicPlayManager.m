//
//  FNMusicPlayManager.m
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicPlayManager.h"

@implementation FNMusicPlayManager
@synthesize playingMusic = _playingMusic;
@synthesize playListId = _playListId;
@synthesize playList = _playList;
@synthesize playListInfo = _playListInfo;

+ (FNMusicPlayManager *)sharedManager
{
    static FNMusicPlayManager *sharedMusicManager;
    static dispatch_once_t doneSharedMusicManager;
    dispatch_once(&doneSharedMusicManager, ^{ 
        sharedMusicManager = [FNMusicPlayManager new];
        [[NSNotificationCenter defaultCenter] addObserver:sharedMusicManager selector:@selector(artworkLoaded:) name:@"FNAMusicArtWorkLoaded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedMusicManager selector:@selector(playerItemStatusChanged:) name:@"PlayItemStatusChanged" object:nil];
        
        // バックグラウンドでも、再生を続けるために、AVAudioSessionをAVAudioSessionCategoryPlaybackに
        AVAudioSession *session = [AVAudioSession sharedInstance];
        session.delegate = sharedMusicManager; // 電話等から、復帰時に、再生を再開できるように、delegate接続
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    return sharedMusicManager;
}

- (NSString *) playListId
{
    if (self.playListInfo != nil){
        return [self.playListInfo objectForKey:@"code"];
    }
    return nil;
}

// play listをセットする
- (void)setPlayList:(NSArray *)playList playListInfo:(NSDictionary *)playListInfo;
{
    if (_playList != playList){
        _playList = playList;
        _playListInfo = playListInfo;
        
    }
}
- (void)play
{
    
}
- (void)pause
{
    
}
- (void)next
{
    
}
- (void)prev
{
    
}
- (void)playOrPause
{
    
}
- (void)playAtIndex:(NSInteger)index
{
    
}

#pragma mark - Retreave RSS Data for iTunes Store
- (void)loadRSS:(NSString *)url{
 
    
}

#pragma mark - Remote-control event handling
// Respond to remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self prev];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self next];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Interruption event handling
- (void)beginInterruption
{
    if (self.playingMusic){
        _shouldResume = YES;
    }else{
        _shouldResume = NO;
    }
    self.playingMusic = NO;
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionFlags_ShouldResume){
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        if (_shouldResume){
            [self play];
        }
    }    
}


@end
