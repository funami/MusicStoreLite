//
//  FNMusicListCell.m
//  MusicStoreLite
//
//  Created by funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicListCell.h"

@implementation FNMusicListCell
@synthesize myImageView;
@synthesize myTextLabel;
@synthesize myDetailTextLabel;
@synthesize myPriceTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
