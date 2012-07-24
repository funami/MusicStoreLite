//
//  FNMusicStoreViewController.m
//  MusicStoreLite
//
//  Created by Takao Funami on 12/07/23.
//  Copyright (c) 2012年 Recruit. All rights reserved.
//

#import "FNMusicStoreViewController.h"
#import "AFNetworking.h"
#import "FNMusicListViewController.h"

@interface FNMusicStoreViewController ()

@property (nonatomic,retain) NSArray *objects;
- (void)prepareStoreListData;

@end

@implementation FNMusicStoreViewController
@synthesize objects = _objects;

#pragma mark - StoreInfo
- (void)prepareStoreListData
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music_store" ofType:@"json"]];
    
    self.objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    /*
    NSURL *url = [NSURL URLWithString:@"http://rss.rdy.jp/itm/music_store.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.objects = JSON;
        
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //オフラインの時は、デフォルトデータを表示する
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music_store" ofType:@"json"]];
        
        self.objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation start];
     */
}

#pragma mark - ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self prepareStoreListData];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CountrryCell"];
    
    NSDictionary *object = [_objects objectAtIndex:indexPath.row];
    NSString *labelText = [NSString stringWithFormat:@"%@",[object objectForKey:@"display"]];
    NSString *detailText = [NSString stringWithFormat:@"%@",[object objectForKey:@"code"]];
    cell.textLabel.text = labelText;
    cell.detailTextLabel.text = detailText;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[object objectForKey:@"code"]]];
    cell.imageView.frame = CGRectMake(0, 0, 55, 55);
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}


@end
