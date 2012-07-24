//
//  FNMusicPlayManager.m
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicPlayManager.h"

static const NSString *PlayerStatusContext;
static const NSString *CurrentItemChangedContext;
static const NSString *PlayerRateContext;

@implementation FNMusicPlayManager
@synthesize playingMusic = _playingMusic;
@synthesize playListId = _playListId;
@synthesize playList = _playList;
@synthesize playListInfo = _playListInfo;
@synthesize currentIndex = _currentIndex;
@synthesize delegate = _delegate;

+ (FNMusicPlayManager *)sharedManager
{
    static FNMusicPlayManager *sharedMusicManager;
    static dispatch_once_t doneSharedMusicManager;
    dispatch_once(&doneSharedMusicManager, ^{ 
        sharedMusicManager = [FNMusicPlayManager new];
        
        //アートワークの読み込みを非同期で行うため
        [[NSNotificationCenter defaultCenter] addObserver:sharedMusicManager selector:@selector(artworkLoaded:) name:@"FNAMusicArtWorkLoaded" object:nil];

        
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
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];

}

- (NSString *) playListId
{
    if (self.playListInfo != nil){
        return [self.playListInfo objectForKey:@"code"];
    }
    return nil;
}


-(void)setCurrentIndex:(NSUInteger)currentIndex
{
    int pasetIndex = _currentIndex;
    if (_currentIndex != currentIndex){
        _currentIndex = currentIndex;
    }
    [self updatePlayingInfo];
    if (self.delegate)
        [self.delegate musicManeger:self MusicDidChanged:_currentIndex past:pasetIndex];
    
    
}
-(void)setPlayingMusic:(BOOL)playingMusic
{
    if (_playingMusic != playingMusic){
        _playingMusic = playingMusic;
    }
    if (self.delegate){
        if (_playingMusic){
            [self.delegate musicManeger:self MusicDidStarted:_playingMusic];
        }else{
            [self.delegate musicManeger:self MusicDidStoped:_playingMusic];
        }
    }
}

//既に再生中なら、停止して、Playerを破棄する
- (void)stop
{
    [self pause];
    _player = nil;
}

- (void)play
{
    if (self.playingMusic == NO){
        if (_player != nil){
            [_player play];            
            self.playingMusic = YES;
            _shouldResume = YES;
        }else{
            [self playAtIndex:self.currentIndex];
        }
    }
}

- (void)pause
{
    if (self.playingMusic){
        [_player pause];
        self.playingMusic = NO;
        _shouldResume = NO;
    }
}

- (int)nextIndex
{
    int nextIndex = self.currentIndex+1;
    if (nextIndex > self.playList.count -1){
        nextIndex = 0;
    }
    return nextIndex;
}
- (void)next
{
    
    if (self.playingMusic){
        [_player advanceToNextItem];
    }else{
        [self stop];
        self.currentIndex = [self nextIndex];
    }


}

- (int)prevIndex
{
    int prevIndex = self.currentIndex-1;
    if (prevIndex < 0){
        prevIndex = self.playList.count -1;
    }
    return prevIndex;
}
- (void)prev
{
    int prevIndex =[self prevIndex];
    if (self.playingMusic){
        [self playAtIndex:prevIndex];
    }else{
        [self stop];
        self.currentIndex = prevIndex;
    }
    
}

- (void)playOrPause
{
    if (self.playingMusic){
        [self pause];
    }else{
        [self play];
    }
}
- (void)playAtIndex:(NSInteger)index
{
    
    self.currentIndex = index;
    
    dispatch_queue_t q_global;
    q_global = dispatch_get_global_queue(0, 0);
    dispatch_async(q_global, ^{
        
        [self stop];
        
        NSMutableArray *palyerItems = [NSMutableArray array];
        int musicCount = [_playList count];
        // palyerItems に　AVPlayerItemを追加
        for (int i = index ; i < musicCount ; i++){
            NSURL *url = [_palyURLs objectAtIndex:i];
            if (url != nil){
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                [palyerItems addObject:playerItem];
            }
        }
        
        // AVQueuePlayerのインスタンスつくる
        _player = [AVQueuePlayer queuePlayerWithItems:palyerItems];
        
        [_player addObserver:self forKeyPath:@"status" options:0 context:&PlayerStatusContext];
        [_player addObserver:self forKeyPath:@"currentItem" options:0 context:&CurrentItemChangedContext];
        [_player addObserver:self forKeyPath:@"rate" options:0 context:&PlayerRateContext];
    });
}

// play listをセットする
- (void)setPlayList:(NSArray *)playList playListInfo:(NSDictionary *)playListInfo;
{
    if (_playList != playList){
        _playList = playList;
        _playListInfo = playListInfo;
        _artworks = [NSMutableDictionary dictionary];
        self.currentIndex = 0;
        
        [self stop];
        
        NSMutableArray *urls = [NSMutableArray array];
        for (int i = 0 ; i < [_playList count] ; i++){
            NSDictionary *item = [_playList objectAtIndex:i];
            NSArray *links = [item objectForKey:@"link"];
            NSURL *url = nil;
            for (NSDictionary *link in links){
                NSDictionary *attributes = [link objectForKey:@"attributes"];
                if (attributes != nil){
                    if ([[attributes objectForKey:@"im:assetType"] isEqualToString:@"preview"]){
                        NSString *urlString = [attributes objectForKey:@"href"];
                        url = [NSURL URLWithString:urlString];
                    }
                }
            }
            [urls addObject:url];
        }
        _palyURLs = urls;
    }
}


#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if (context == &PlayerStatusContext) {
        AVPlayer *thePlayer = (AVPlayer *)object;
        if ([thePlayer status] == AVPlayerStatusFailed) {
            NSError *error = [thePlayer error];
            NSLog(@"Error:%@",error);
            // Respond to error: for example, display an alert sheet.
            self.playingMusic = NO;
            return;
            
        }else if ([thePlayer status] == AVPlayerStatusReadyToPlay){
            // if status OK start play
            
            [self play];

            
        }else{
            NSLog(@"AVPlayerStatusNone:%@",object);
        }
        
    }else if (context == &CurrentItemChangedContext){
        
        AVPlayerItem *currentItem = [_player currentItem];
        AVURLAsset *asset = (AVURLAsset *)currentItem.asset;
        //NSLog(@"currentItem%@.asset:%@",currentItem,currentItem.asset);
        
        if (currentItem != nil){
            self.currentIndex = [_palyURLs indexOfObject:asset.URL];
        }else{
            [self pause];
        }
        
    }else if (context == &PlayerRateContext){
        
    }
    
    return;
    
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

#pragma mark - MPNowPlayingInfoCenter
// ロック画面に曲名を表示する
- (MPMediaItemArtwork *)artwork:(NSString *)urlString
{
    
    MPMediaItemArtwork *artwork = [_artworks objectForKey:urlString];
    
    if (artwork != nil){
        return artwork;
    }else{
        NSURL *imageURL = nil;
        imageURL = [NSURL URLWithString:urlString];
        if (imageURL != nil){
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *res, NSData *data, NSError *error){
                                       if (!error){
                                           MPMediaItemArtwork *art = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:data]];
                                           [_artworks setObject:art forKey:urlString];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"FNAMusicArtWorkLoaded" object:self];
                                       }else{
    #ifdef DEBUG
                                           NSLog(@"error cant retrieve artwork");
    #endif
                                       }
                                   }];
        }
    }
    return nil;
}


- (void)updatePlayingInfo{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSDictionary *item = [self.playList objectAtIndex:self.currentIndex];
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:[[item objectForKey:@"im:name"] objectForKey:@"label"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[[item objectForKey:@"im:artist"] objectForKey:@"label"] forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[[[item objectForKey:@"im:collection"] objectForKey:@"im:name"] objectForKey:@"label"] forKey:MPMediaItemPropertyAlbumTitle];
        
        NSURL *imageURL = nil;
        NSArray *imgs = [item objectForKey:@"im:image"];
        for (NSDictionary *img in imgs){
            NSDictionary *attributes = [img objectForKey:@"attributes"];
            if (attributes != nil){
                if ([[attributes objectForKey:@"height"] isEqualToString:@"170"]){
                    NSString *urlString = [img objectForKey:@"label"];
                    imageURL = [NSURL URLWithString:urlString];
                }
            }
        }
        
        MPMediaItemArtwork *artwork = [self artwork:imageURL.absoluteString];
        if (artwork){
            [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
        }else{
            [songInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"no_image.png"]] forKey:MPMediaItemPropertyArtwork];
        }

        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        //NSLog(@"songInfo:%@",songInfo);
        
    }
    
}


- (void)artworkLoaded:(NSNotification *)notification
{
    [self updatePlayingInfo];
}

@end
