//
//  FNMusicListCell.h
//  MusicStoreLite
//
//  Created by funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNMusicListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDetailTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myPriceTextLabel;

@end
