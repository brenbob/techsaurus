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
#import "AFNetworking.h"
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
}

#pragma mark data methods

-(void)requestTerms
{
    NSString *tagsUrl = [Common getUrl:@"tagsUrl" :@""];
    NSURL *url = [NSURL URLWithString:tagsUrl];
//    NSLog(@"url = %@", url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        allTerms = [responseObject objectForKey:@"Tags"];
        sections = [Common getSections:allTerms withKey:@"tag"];

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
    if (isFullTable) {
        return [sections count];
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (isFullTable) {
        return 20.0;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (isFullTable) {
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, [[UIScreen mainScreen] bounds].size.width-40, 20.0)];
        header.font = [UIFont systemFontOfSize:10.0];
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
    if (isFullTable) {
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
    if (isFullTable) {
        // add indexPath.row to starting index of current section
        int itemIndex = [(NSNumber *)[sections objectAtIndex:indexPath.section][1] intValue] + indexPath.row;
        item = [tableData objectAtIndex:itemIndex];
    }
    
	cell.textLabel.text = [item valueForKey:@"tag"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier: @"showByTag" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showByTag"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setSelectedTag:[[self->tableData objectAtIndex:indexPath.row] valueForKey:@"tag"]];
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
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    if (self->sorted) {
        tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:NO selector:@selector(caseInsensitiveCompare:)];
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
    sections = [Common getSections:tableData withKey:@"tag"];
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


@end
