//
//  ListByTagVC.m
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "TermsByTagVC.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "DetailViewController.h"

@implementation TermsByTagVC
@synthesize appDelegate, btnTableActions;
@synthesize selectedTag;


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
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = [NSString stringWithFormat:@"related to '%@'",selectedTag];
        
    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space
    }
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _allTerms = [[NSArray alloc] init];
    
    [self requestTerms:selectedTag];
    
    [btnTableActions addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark data methods

-(void)requestTerms:(NSString*)tag
{
    NSString *termsUrl = [appDelegate.configuration objectForKey:@"termsUrl"];
    if (tag != nil) {
        tag = [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        termsUrl = [termsUrl stringByReplacingOccurrencesOfString:@"<tag>" withString:tag];
    }
    
    NSString *apiDomain;
#ifdef DEVAPI
    apiDomain = [appDelegate.configuration objectForKey:@"apiDomainDev"];
#else
    apiDomain = [appDelegate.configuration objectForKey:@"apiDomainProd"];
#endif
    NSLog(@"url = %@%@",apiDomain,termsUrl);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",apiDomain,termsUrl]];
    
    
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

- (IBAction)sortTable:(id)sender {
    NSLog(@"sortTable %i",[sender selectedSegmentIndex]);
    NSSortDescriptor *ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    if ([sender selectedSegmentIndex] == 1) {
        ageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    }
    NSArray *sortDescriptors = @[ageDescriptor];
    NSArray *sortedArray = [_allTerms sortedArrayUsingDescriptors:sortDescriptors];
    _allTerms = sortedArray;
    [self.tableView reloadData];
}

@end