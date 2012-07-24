//
//  FNMusicListViewController.h
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNMusicPlayManager.h"

@interface FNMusicListViewController : UITableViewController<FNMusicPlayManagerDelegate>

@property (nonatomic,retain) id detailItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;

- (void)updateToolBarButtons;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
@end
