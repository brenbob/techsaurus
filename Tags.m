//
//  TagsVCViewController.m
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//
#import "Tags.h"
#import "AppDelegate.h"
#import "Common.h"
#import "DetailViewController.h"

@interface Tags () {
    
}
@end

bool isFullTable = 0;

@implementation Tags
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
    
    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space
    }
    
    [self requestTerms];
    sorted = 1; // table is initially sorted ASC order
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    [appDelegate trackPV:@"Tags"];
    
}

#pragma mark data methods

-(void)requestTerms
{
    NSString *tagsUrl = [Common getUrl:@"tagsUrl" :@""];
    NSURL *url = [NSURL URLWithString:tagsUrl];
    NSLog(@"url = %@", url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        allTerms = [responseObject objectForKey:@"Tags"];
        sections = [Common getSections:allTerms withKey:@"title"];
        searchResults = [NSMutableArray arrayWithCapacity:[allTerms count]];

        // on initial launch, show high-level categories
        [self getCategories];
        self->tableData = categories; // display categories in tableview on initial load
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
    if (tableView == self.searchDisplayController.searchResultsTableView || !isFullTable) {
        return 1;
    } else {
        return [sections count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView || !isFullTable) {
        return 0;
    } else {
        return 20.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (isFullTable && tableView != self.searchDisplayController.searchResultsTableView) {
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, [[UIScreen mainScreen] bounds].size.width-40, 20.0)];
        header.font = [UIFont systemFontOfSize:12.0];
        header.textAlignment = NSTextAlignmentCenter ;
        header.backgroundColor = [UIColor lightGrayColor];
        header.textColor = [UIColor whiteColor];
        header.text = [sections objectAtIndex:section][0];
        return header;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else if (isFullTable) {
        return [(NSNumber *)[sections objectAtIndex:section][2] intValue];
    } else {
        return [self->tableData count];
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
    
    NSArray* item = [tableData objectAtIndex:indexPath.row];
    if (tView == self.searchDisplayController.searchResultsTableView) {
        item = [searchResults objectAtIndex:indexPath.row];
    } else if (isFullTable) {
        // add indexPath.row to starting index of current section
        int itemIndex = [[sections objectAtIndex:indexPath.section][1] intValue] + (int)indexPath.row;
        item = [tableData objectAtIndex:itemIndex];
    }
    
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier: @"showByTag" sender: tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showByTag"]) {
        NSArray *selectedItem = nil;

        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            selectedItem = [searchResults objectAtIndex:indexPath.row];
            // dismiss search results view
            [self.searchDisplayController setActive:NO animated:NO];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            selectedItem = [tableData objectAtIndex:indexPath.row];
        }
        [[segue destinationViewController] setSelectedTag:[selectedItem valueForKey:@"title"]];
    }
}

- (IBAction)switchTable:(id)sender {
    if ([sender selectedSegmentIndex] == 0) {
        self->tableData = self->categories;
    } else {
        self->tableData = self->allTerms;
    }
    isFullTable = [sender selectedSegmentIndex];
    [self.tableView reloadData];
}

- (IBAction)sortTable {
    
    UIImage *tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationLeft];
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    if (self->sorted) {
        tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        sorted = 0;
    } else {
        sorted = 1;
        // rotate 180
        tmpImage = [UIImage imageWithCGImage:_btnSortTable.image.CGImage scale:2.0 orientation:UIImageOrientationDown];
    }
    _btnSortTable.image = tmpImage;
    
    NSArray *sortDescriptors = @[tagDescriptor];
    NSArray *sortedArray = [self->tableData sortedArrayUsingDescriptors:sortDescriptors];
    self->tableData = [sortedArray mutableCopy];
    sections = [Common getSections:tableData withKey:@"title"];
    [self.tableView reloadData];
}

-(void)getCategories {
    
    self->categories = [[NSMutableArray alloc] init];
    for (int i=0; i < [self->allTerms count]; i++) {
        int cat = [[self->allTerms[i] valueForKey:@"isCat"] intValue];
        if (cat > 0) {
            [self->categories addObject:self->allTerms[i]];
        }
    }
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Remove existing objects from the filtered search array
    [searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title beginswith[c] %@", searchText];
    searchResults = [[tableData filteredArrayUsingPredicate:resultPredicate] mutableCopy];
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
