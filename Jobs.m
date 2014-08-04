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
NSString *searchTermPrev = @"";


#pragma mark view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Salaries";
	_appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.hidden = YES;
    self.updated.hidden = YES;
    self.source.hidden = YES;


}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (_keyword != NULL) {
        self.searchTerm.text = _keyword;
        self.uiLoading.hidden = NO;
        [self.uiLoading startAnimating];
        [self requestJobs:nil];
    }

}

#pragma mark data methods


- (IBAction)requestJobs:(id)sender
{
    if (sender) {
        BOOL dismiss = [self textFieldShouldReturn:_searchTerm];
        dismiss = [self textFieldShouldReturn:_searchLocation];
    }
    
    NSString * searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainProd"],[self.appDelegate.configuration objectForKey:@"trendsUrl"]];
    
#ifdef JOBS_API_DEV
    searchUrl = [NSString stringWithFormat:@"%@%@",[self.appDelegate.configuration objectForKey:@"jobsApiDomainDev"],[self.appDelegate.configuration objectForKey:@"trendsUrl"]];
#endif
    
	NSString *query = self.searchTerm.text;
    if (![query integerValue]) {
        query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<kw>" withString:query];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<loc>" withString:_searchLocation.text];
    
    NSURL *url = [NSURL URLWithString:searchUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.salaries = responseObject;
        // set the 'updated' label text
        self.updated.text = [_salaries[[_salaries count]-2 ] valueForKey:@"updated"];
        self.tableView.hidden = NO;
        self.updated.hidden = NO;
        self.source.hidden = NO;

        [self.tableView reloadData];
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

    return [self.salaries count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = (indexPath.row == 0) ? @"avg" : @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *tmpJob = [self.salaries objectAtIndex:indexPath.row];

    if ([tmpJob valueForKey:@"title"]) {
        UILabel *label;
        
        NSString *leftText = (indexPath.row == 0) ? [NSString stringWithFormat:@"Avg. '%@' salaries", [tmpJob valueForKey:@"title"]] : [tmpJob valueForKey:@"title"];
        label = (UILabel *)[cell viewWithTag:1];
        label.text = leftText;
        
        label = (UILabel *)[cell viewWithTag:2];
        label.text = [tmpJob valueForKey:@"salary"];

    }
    return cell;
}

-(IBAction)linkToSource {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.appDelegate.configuration objectForKey:@"simplyHiredUrl"]]];

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
