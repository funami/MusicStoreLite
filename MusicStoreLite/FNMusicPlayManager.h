//
//  FNMusicPlayManager.h
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@class FNMusicPlayManager;
@protocol FNMusicPlayManagerDelegate <NSObject>

#pragma mark - FNMusicPlayManagerDelegate
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidChanged:(NSInteger)index past:(NSInteger)past;
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidStarted:(NSInteger)index;
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidStoped:(NSInteger)index;

@end

@interface FNMusicPlayManager : NSObject<AVAudioSessionDelegate>
{
    BOOL _shouldResume;
    NSArray *_palyURLs;
    NSMutableDictionary *_artworks;
    AVQueuePlayer *_player;
}

@property (nonatomic) BOOL playingMusic;
@property (nonatomic,readonly) NSString *playListId;
@property (nonatomic,strong) NSDictionary *playListInfo;
@property (nonatomic,strong) NSArray *playList;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic,assign) id delegate;

+ (FNMusicPlayManager *)sharedManager;

- (void)setPlayList:(NSArray *)playList playListInfo:(NSDictionary *)playListInfo;
- (void)play;
- (void)pause;
- (void)next;
- (void)prev;
- (void)playOrPause;
- (void)playAtIndex:(NSInteger)index;
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent ;


@end
