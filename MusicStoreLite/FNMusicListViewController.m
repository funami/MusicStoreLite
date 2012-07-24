//
//  FNMusicListViewController.m
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/24.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicListViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "FNMusicListCell.h"


@interface FNMusicListViewController ()
@property (nonatomic,retain) NSArray *objects;

@end

@implementation FNMusicListViewController
@synthesize detailItem = _detailItem;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize objects = _objects;

#pragma mark - RSS
- (void)loadRSS
{
    NSString *countryCode = [self.detailItem objectForKey:@"code"];
    
    // 既に、同じストアで再生中ならそのまま、引き継ぐ
    if ([[FNMusicPlayManager sharedManager].playListId isEqualToString:countryCode]){
        self.objects = [[FNMusicPlayManager sharedManager] playList];
        [FNMusicPlayManager sharedManager].delegate = self;
        [self updateToolBarButtons];
    }else{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/%@/rss/topsongs/limit=50/json",countryCode]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.objects = [[JSON objectForKey:@"feed"] objectForKey:@"entry"]; 
            
            [[FNMusicPlayManager sharedManager] setPlayList:self.objects playListInfo:self.detailItem];
            [FNMusicPlayManager sharedManager].delegate = self;
            [self updateToolBarButtons];
            
            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            //ネットワーク不調のときは失敗
            [self.navigationItem setPrompt:[error localizedDescription]];
            NSLog(@"Error:%@",error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [operation start];    
    }
    self.title = [self.detailItem objectForKey:@"display"];
        
    
}


#pragma mark - TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadRSS];
}

- (void)viewDidUnload
{
    [FNMusicPlayManager sharedManager].delegate = nil;
    [self setPlayButton:nil];
    [self setPauseButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [FNMusicPlayManager sharedManager].delegate = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.objects count];
}

- (void)configureCell:(FNMusicListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.objects objectAtIndex:indexPath.row];
    NSString *labelText = [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[[item objectForKey:@"im:name"] objectForKey:@"label"]];
    cell.myTextLabel.text = labelText;
    
    NSString *detailText = [NSString stringWithFormat:@"%@",[[item objectForKey:@"im:artist"] objectForKey:@"label" ]];
    cell.myDetailTextLabel.text = detailText;;
    
    cell.myPriceTextLabel.text = [[item objectForKey:@"im:price"] objectForKey:@"label" ];
    NSURL *imageURL = nil;
    NSArray *imgs = [item objectForKey:@"im:image"];
    for (NSDictionary *img in imgs){
        NSDictionary *attributes = [img objectForKey:@"attributes"];
        if (attributes != nil){
            if ([[attributes objectForKey:@"height"] isEqualToString:@"55"]){
                NSString *urlString = [img objectForKey:@"label"];
                imageURL = [NSURL URLWithString:urlString];
            }
        }
    }
    [cell.myImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"noImage.png"]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicCell";
    FNMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[FNMusicPlayManager sharedManager] playAtIndex:indexPath.row];
}

#pragma mark - Music play

- (void)updateToolBarButtons{
    if ([FNMusicPlayManager sharedManager].playingMusic){
        [self.pauseButton setEnabled:YES];
        [self.playButton setEnabled:NO];
    }else{
        [self.pauseButton setEnabled:NO];
        [self.playButton setEnabled:YES];
    }
    int index = [FNMusicPlayManager sharedManager].currentIndex;
    NSDictionary *item = [self.objects objectAtIndex:index];
    [self.navigationItem setPrompt:[NSString stringWithFormat:@"%d.%@",index+1,[[item objectForKey:@"title"] objectForKey:@"label"]]];
}

- (IBAction)play:(id)sender {
    [[FNMusicPlayManager sharedManager] play];
}

- (IBAction)pause:(id)sender {
    [[FNMusicPlayManager sharedManager] pause];
}

- (IBAction)next:(id)sender {
    [[FNMusicPlayManager sharedManager] next];
}

- (IBAction)prev:(id)sender {
    [[FNMusicPlayManager sharedManager] prev];
}

#pragma mark - FNMusicPlayManagerDelegate
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidChanged:(NSInteger)index past:(NSInteger)past
{
    [self updateToolBarButtons];
}
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidStarted:(NSInteger)index
{
    [self updateToolBarButtons];
}
- (void)musicManeger:(FNMusicPlayManager *)musicManager MusicDidStoped:(NSInteger)index
{
    [self updateToolBarButtons];
}

@end
