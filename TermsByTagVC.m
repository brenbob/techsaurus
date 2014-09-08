//
//  ListByTagVC.m
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "TermsByTagVC.h"
#import "AppDelegate.h"
#import "Common.h"
#import "DetailViewController.h"

@implementation TermsByTagVC
@synthesize appDelegate, selectedTag;

int sorted = 1;


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [self setCustomTitle:selectedTag :@"Tags related to"];

    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space
    }
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _allTerms = [[NSArray alloc] init];
    
    [self requestTerms:selectedTag];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Log pageview w/ Google Analytics
    [appDelegate trackPVFull:@"TermsbyTag" :@"page view" :@"page view" :selectedTag :nil];

}

-(UIView*)setCustomTitle:(NSString*)title :(NSString*)subtitle {
    // make custom title and sub-title
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0,0,160,12)];
    sub.textColor = [UIColor darkGrayColor];
    sub.font = [UIFont systemFontOfSize:10];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.text = subtitle;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,8,160,30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title.capitalizedString;
    
    UIView *tv = [[UIView alloc] initWithFrame:CGRectMake(0,0,160,32)];
    [tv addSubview:label];
    [tv addSubview:sub];
    return tv;
}

#pragma mark data methods

-(void)requestTerms:(NSString*)tag
{
    NSString *termsUrl = [Common getUrl:@"termsUrl" :tag];
    NSURL *url = [NSURL URLWithString:termsUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _allTerms = [responseObject objectForKey:@"Terms"];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
}




#pragma mark cleanup

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [[_sections objectAtIndex:section] integerValue];
    // get key matching 'section' value
    // use key to get section count
    // convert to integer value
    //    return [[_sections valueForKey:[[_sections allKeys] objectAtIndex:section]] integerValue];
    return [_allTerms count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
        
	}
    NSArray *item = [self.allTerms objectAtIndex:indexPath.row];
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *object = _allTerms[indexPath.row];
    self.detailViewController.detailItem = object;
    [self performSegueWithIdentifier: @"showDetail" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *object = _allTerms[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (IBAction)sortTable {

    UIImage *tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationLeft];

    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    if (sorted) {
        titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        sorted = 0;
    } else {
        sorted = 1;
        // rotate 180
        tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationDown];
    }
    _btnSortTable.image = tmpImage;
    
    NSArray *sortDescriptors = @[titleDescriptor];
    NSArray *sortedArray = [_allTerms sortedArrayUsingDescriptors:sortDescriptors];
    _allTerms = sortedArray;
    [self.tableView reloadData];
}

@end