//
//  Jobs.m
//  techlingo
//
//  Created by Brenden West on 7/6/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Jobs.h"
#import "AppDelegate.h"
#import "Common.h"

@interface Jobs ()

@end

@implementation Jobs

NSString *curLocation = @"";
NSString *searchTermPrev = @"";


#pragma mark view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	_appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.hidden = YES;
    self.btnSimplyHired.hidden = YES;
    self.btnJobAgent.hidden = YES;
    [self.uiLoading stopAnimating];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (_keyword != NULL) {
        NSLog(@"has keyword");
        self.searchTerm.text = _keyword;
        [self requestJobs:nil];
    }

    // Log pageview w/ Google Analytics
    [_appDelegate trackPVFull:@"Jobs" :@"page view" :@"search" :_keyword :nil];

}

#pragma mark data methods


- (IBAction)requestJobs:(id)sender
{
    if (sender) {
        [self textFieldShouldReturn:_searchTerm];
        [self textFieldShouldReturn:_searchLocation];
    }
    
    // show loading indicator
    [self.uiLoading startAnimating];

    NSString * searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainProd"],[self.appDelegate.configuration objectForKey:@"trendsUrl"]];
    
#ifdef JOBS_API_DEV
    searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainDev"],[self.appDelegate.configuration objectForKey:@"trendsUrl"]];
#endif
    
	NSString *query = self.searchTerm.text;
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<kw>" withString:query];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<loc>" withString:_searchLocation.text];
    searchUrl = [searchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"searchUrl = %@",searchUrl);
    
    NSURL *url = [NSURL URLWithString:searchUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.salaries = responseObject;
        // set the 'updated' label text
        self.tableView.hidden = NO;
        self.btnSimplyHired.hidden = NO;
        self.btnJobAgent.hidden = NO;
        [self.uiLoading stopAnimating];

        [self.tableView reloadData];
        
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
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    } else {
        return [self.salaries count]-1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 20.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return @"  Avg. salary for related jobs";
    } else {
        return nil;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = (indexPath.section == 0) ? @"avg" : @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // add indexPath.row to starting index of current section
    int indexForSection = indexPath.row + indexPath.section; // section 1 starts at index 1
    
    NSArray *tmpJob = [self.salaries objectAtIndex:indexForSection];

    if ([tmpJob valueForKey:@"title"]) {
        UILabel *label;
        
        NSString *leftText = (indexPath.section == 0) ? [NSString stringWithFormat:@"Avg. '%@' salaries", [tmpJob valueForKey:@"title"]] : [tmpJob valueForKey:@"title"];
        label = (UILabel *)[cell viewWithTag:1];
        label.text = leftText;
        
        label = (UILabel *)[cell viewWithTag:2];
        label.text = [tmpJob valueForKey:@"salary"];

    }
    return cell;
}

-(IBAction)linkToSite:(id)sender {

    if (sender == _btnSimplyHired) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.appDelegate.configuration objectForKey:@"simplyHiredUrl"]]];
    } else if (sender == _btnJobAgent) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.appDelegate.configuration objectForKey:@"jobAgentUrl"]]];
    }

}

#pragma mark Text Field methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
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
