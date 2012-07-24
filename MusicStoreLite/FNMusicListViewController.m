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
#import "FNMusicPlayManeger.h"
#import "FNMusicListCell.h"


@interface FNMusicListViewController ()
@property (nonatomic,retain) NSArray *objects;

@end

@implementation FNMusicListViewController
@synthesize detailItem = _detailItem;
@synthesize objects = _objects;

#pragma mark - RSS
- (void)loadRSS
{
    NSString *countryCode = [self.detailItem objectForKey:@"code"];
    
    if ([[FNMusicPlayManeger sharedManager].playListId isEqualToString:countryCode]){
        self.objects = [[FNMusicPlayManeger sharedManager] playList];
    }else{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/%@/rss/topsongs/limit=100/json",countryCode]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.objects = [[JSON objectForKey:@"feed"] objectForKey:@"entry"]; 
            
            [[FNMusicPlayManeger sharedManager] setPlayList:self.objects playListId:countryCode];
            
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self loadRSS];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicCell";
    FNMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
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
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
