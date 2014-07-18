//
//  Jobs.m
//  techlingo
//
//  Created by Brenden West on 7/6/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Jobs.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Common.h"

@interface Jobs ()

@end

@implementation Jobs

NSString *curLocation = @"Seattle, WA";
NSString *searchUrl = @"";
NSString *searchTermPrev = @"";


#pragma mark view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Jobs";
	_appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // set font size for segmented control
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor blackColor],UITextAttributeTextColor,
                                                             [UIColor clearColor], UITextAttributeTextShadowColor,
                                                             [UIFont fontWithName:@"HelveticaNeue" size:12.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0],UITextAttributeTextColor,
                                                             [UIColor clearColor], UITextAttributeTextShadowColor,
                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                             [UIFont fontWithName:@"HelveticaNeue" size:12.0], UITextAttributeFont, nil] forState:UIControlStateSelected];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    if (_searchTerm && ![searchTermPrev isEqualToString:_searchTerm]) {
        // new search requested.
        self.tableView.hidden = YES;
        self.btnJobSite.hidden = YES;
        self.uiLoading.hidden = NO;
        [self.uiLoading startAnimating];
        searchTermPrev = _searchTerm;
		[self requestJobs:nil];
    } else {
        [self.uiLoading stopAnimating];
    }
    
    
//    lblSearch.text = [NSString stringWithFormat:NSLocalizedString(@"STR_RESULTS_FOR", nil),txtSearch,curLocation];
}

#pragma mark data methods


- (IBAction)switchJobSite:(id)sender {
    NSString *tag = [[_appDelegate.configuration objectForKey:@"jobSiteList"] objectAtIndex:_btnJobSite.selectedSegmentIndex];
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.link contains[c] '%@'",tag]];
    
    self.jobsForSite = [self.jobsAll filteredArrayUsingPredicate:sPredicate];
    
    if ([self.jobsForSite count] > 0) {
        [self.tableView reloadData];
    } else {
		UIAlertView *noJobs = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"STR_NO_LISTINGS", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
		[noJobs show];
    }
}


- (void)requestJobs:(id)sender
{
    // using a stripped-down version of request builder from Job Agent
    // Location is blank and country set to US
    // no support for user-defined max, age, or distance
	NSString *query = self.searchTerm;
    
    if (![query integerValue]) {
        query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
#ifdef JOBS_API_DEV
    searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainDev"],[self.appDelegate.configuration objectForKey:@"jobsSearchUrl"]];
#else
    searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainProd"],[self.appDelegate.configuration objectForKey:@"jobsSearchUrl"]];
#endif
    
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<kw>" withString:query];
    
    
    NSURL *url = [NSURL URLWithString:searchUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.jobsAll = [responseObject objectForKey:@"jobs"];
        
        [self switchJobSite:nil];
        
        self.tableView.hidden = NO;
        self.btnJobSite.hidden = NO;
        [self.uiLoading stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.jobsForSite count];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *tmpJob = [self.jobsForSite objectAtIndex:indexPath.row];
    
	cell.textLabel.text = [tmpJob valueForKey:@"title"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ~ %@ ~ %@",[Common getShortDate:[tmpJob valueForKey:@"pubdate"]], [tmpJob valueForKey:@"company"], [tmpJob valueForKey:@"location"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tmpJob = [self.jobsForSite objectAtIndex:indexPath.row];
    // link to job detail in web view
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[tmpJob valueForKey:@"link"]]];
	
}

- (IBAction)loadJobAgent {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.appDelegate.configuration objectForKey:@"jobAgentUrl"]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
