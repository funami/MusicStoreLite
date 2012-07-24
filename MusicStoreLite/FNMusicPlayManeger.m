//
//  FNMusicPlayManeger.m
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicPlayManeger.h"

@implementation FNMusicPlayManeger
@synthesize playingMusic = _playingMusic;
@synthesize playListId = _playListId;
@synthesize playList = _playList;

+ (FNMusicPlayManeger *)sharedManager
{
    static FNMusicPlayManeger *sharedMusicManeger;
    static dispatch_once_t doneSharedMusicManeger;
    dispatch_once(&doneSharedMusicManeger, ^{ 
        sharedMusicManeger = [FNMusicPlayManeger new]; 
        [[NSNotificationCenter defaultCenter] addObserver:sharedMusicManeger selector:@selector(artworkLoaded:) name:@"FNAMusicArtWorkLoaded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedMusicManeger selector:@selector(playerItemStatusChanged:) name:@"PlayItemStatusChanged" object:nil];
        
        // バックグラウンドでも、再生を続けるために、AVAudioSessionをAVAudioSessionCategoryPlaybackに
        AVAudioSession *session = [AVAudioSession sharedInstance];
        session.delegate = sharedMusicManeger; // 電話等から、復帰時に、再生を再開できるように、delegate接続
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    return sharedMusicManeger;       
}

// play listをセットする
- (void)setPlayList:(NSArray *)playList playListId:(NSString *)playListId
{
    if (_playList != playList){
        _playList = playList;
        _playListId = playListId;
        
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
