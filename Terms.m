//
//  MasterViewController.m
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Terms.h"
#import "AppDelegate.h"
#import "Common.h"
#import "DetailViewController.h"

@interface Terms () {

}
@end

@implementation Terms
@synthesize appDelegate;


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
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self requestTerms:nil];
    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    // set flag to indicate whether table sorted in asc or desc order
    sorted = 1;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [appDelegate trackPV:@"Terms"]; // Google Analytics call needs to happen here, or initial launch event not recorded
}


#pragma mark data methods

-(void)requestTerms:(NSString*)tag
{
    
    NSString *termsUrl = [Common getUrl:@"termsUrl" :tag];
    NSURL *url = [NSURL URLWithString:termsUrl];
    NSLog(@"url = %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        allTerms = [responseObject objectForKey:@"Terms"];
        // Initialize the searchResults array with a capacity equal to allTerms capacity
        searchResults = [NSMutableArray arrayWithCapacity:[allTerms count]];

        appDelegate.allTerms = allTerms; // store in appdelegate for use in other views
        sections = [Common getSections:allTerms withKey:@"title"];
        [self.uiLoading stopAnimating];
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
    // return appropriate # of sections for main table or search results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
        
    } else {
        return [sections count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, [[UIScreen mainScreen] bounds].size.width-40, 20.0)];
    header.font = [UIFont systemFontOfSize:12.0];
    header.textAlignment = NSTextAlignmentCenter ;
    header.backgroundColor = [UIColor lightGrayColor];
    header.textColor = [UIColor whiteColor];
    header.text = [sections objectAtIndex:section][0];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return appropriate # of rows per section for main table or search results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [(NSNumber *)[sections objectAtIndex:section][2] intValue];
    }
}


// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
        
	}
    
    // same code used for main table view and search results table view
    NSArray *item = nil;
    if (tView == self.searchDisplayController.searchResultsTableView) {
        item = [searchResults objectAtIndex:indexPath.row];
    } else {
        // add indexPath.row to starting index of current section
        int originalIndex = [[sections objectAtIndex:indexPath.section][1] intValue] + (int)indexPath.row;
        item = [allTerms objectAtIndex:originalIndex];
    }
    
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self performSegueWithIdentifier: @"showDetail" sender: tableView];
}

- (IBAction)sortTable {
    
    UIImage *tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationLeft];
    
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    if (self->sorted) {
        titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        sorted = 0;
    } else {
        // rotate 180
        tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationDown];
        sorted = 1;
    }
    _btnSortTable.image = tmpImage;
    
    NSArray *sortDescriptors = @[titleDescriptor];
    NSArray *sortedArray = [allTerms sortedArrayUsingDescriptors:sortDescriptors];
    allTerms = sortedArray;
    sections = [Common getSections:allTerms withKey:@"title"];
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        int itemIndex=0;
        NSArray *object = nil;

        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            object = [searchResults objectAtIndex:indexPath.row];
            // dismiss search results view
            [self.searchDisplayController setActive:NO animated:NO];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            itemIndex = [[sections objectAtIndex:indexPath.section][1] intValue] + (int)indexPath.row;
            object = [allTerms objectAtIndex:itemIndex];
        }
        
        [[segue destinationViewController] setDetailItem:object];
    }
}



#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Remove existing objects from the filtered search array
    [searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title beginswith[c] %@", searchText];
    searchResults = [[allTerms filteredArrayUsingPredicate:resultPredicate] mutableCopy];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)setCorrectFrames
{
    // Here we set the search_results frame to avoid overlay bug and ensure search bar remains visible
    CGRect searchDisplayerFrame = self.searchDisplayController.searchResultsTableView.superview.frame;
    searchDisplayerFrame.origin.y = CGRectGetMaxY(self.searchDisplayController.searchBar.frame);
    searchDisplayerFrame.size.height -= searchDisplayerFrame.origin.y;
    self.searchDisplayController.searchResultsTableView.superview.frame = searchDisplayerFrame;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self setCorrectFrames];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self setCorrectFrames];
}



@end
