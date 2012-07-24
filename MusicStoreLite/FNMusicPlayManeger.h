//
//  FNMusicPlayManeger.h
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@class FNMusicPlayManeger;
@protocol FNMusicPlayManegerDelegate <NSObject>

/* musicがなくなった場合は、indexはNSNotFoundになる */
- (void)musicManeger:(FNMusicPlayManeger *)musicManager MusicDidChanged:(NSInteger)index past:(NSInteger)past;
- (void)musicManeger:(FNMusicPlayManeger *)musicManager MusicDidStarted:(NSInteger)index;
- (void)musicManeger:(FNMusicPlayManeger *)musicManager MusicDidStoped:(NSInteger)index;

@end

@interface FNMusicPlayManeger : NSObject<AVAudioSessionDelegate>
{
    BOOL _shouldResume;
    AVQueuePlayer *_player;
}

@property (nonatomic) BOOL playingMusic;
@property (nonatomic,strong) NSString *playListId;
@property (nonatomic,strong) NSArray *playList;

+ (FNMusicPlayManeger *)sharedManager;

- (void)setPlayList:(NSArray *)playList playListId:(NSString *)playListID;
- (void)play;
- (void)pause;
- (void)next;
- (void)prev;
- (void)playOrPause;
- (void)playAtIndex:(NSInteger)index;


@end
