//
//  TVHStatusSubscriptionsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSubscriptionsViewController.h"
#import "CKRefreshControl.h"
#import "WBErrorNoticeView.h"

@interface TVHStatusSubscriptionsViewController ()
@property (strong, nonatomic) TVHStatusSubscriptionsStore *statusStore;
@end

@implementation TVHStatusSubscriptionsViewController

- (TVHStatusSubscriptionsStore*) statusStore {
    if ( _statusStore == nil) {
        _statusStore = [TVHStatusSubscriptionsStore sharedInstance];
    }
    return _statusStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.statusStore setDelegate:self];
    [self.statusStore fetchStatusSubscriptions];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadStatusSubscriptions {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.tableView reloadData];
    [self.statusStore fetchStatusSubscriptions];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.statusStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubscriptionStoreTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    TVHStatusSubscription *subscription = [self.statusStore objectAtIndex:indexPath.row];
    
    UILabel *channelLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *serviceLabel = (UILabel *)[cell viewWithTag:101];
	
    channelLabel.text = subscription.channel;
    serviceLabel.text = subscription.service;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)didLoadTags {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorStatusSubscriptionsStore:(NSError *)error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.description];
    [notice setSticky:true];
    [notice show];
    
    [self.refreshControl endRefreshing];
}


@end