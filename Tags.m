//
//  TagsVCViewController.m
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//
#import "Tags.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "DetailViewController.h"

@interface Tags () {
    
}
@end

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
    
    self.title = @"Tags";
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self->allTags = [[NSArray alloc] init];
    
    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space
    }
    
    [self requestTags];
    sorted = 1; // table is initially sorted ASC order
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark data methods

-(void)requestTags
{
    
    NSString *tagsUrl = [appDelegate.configuration objectForKey:@"tagsUrl"];
    NSString *apiDomain;
#ifdef DEVAPI
    apiDomain = [appDelegate.configuration objectForKey:@"apiDomainDev"];
#else
    apiDomain = [appDelegate.configuration objectForKey:@"apiDomainProd"];
#endif
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",apiDomain,tagsUrl]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        allTags = [responseObject objectForKey:@"Tags"];
        // on initial launch, show high-level categories
        [self getCategories];
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
    return [self->tableData count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
        
	}
	cell.textLabel.text = [[self->tableData objectAtIndex:indexPath.row] valueForKey:@"tag"];
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
        [self getCategories];
    } else {
        self->tableData = [[NSMutableArray alloc] init];
        self->tableData = [self->allTags mutableCopy];
    }
    [self.tableView reloadData];
}

- (IBAction)sortTable {
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    if (self->sorted) {
        tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        sorted = 0;
        [_btnSortTable setTitle:@"A-Z ^" forState:UIControlStateNormal];
    } else {
        sorted = 1;
        [_btnSortTable setTitle:@"A-Z v" forState:UIControlStateNormal];
    }
    NSLog(@"button text = %@",_btnSortTable.titleLabel.text);
    
    NSArray *sortDescriptors = @[tagDescriptor];
    NSArray *sortedArray = [self->tableData sortedArrayUsingDescriptors:sortDescriptors];
    self->tableData = [sortedArray mutableCopy];
    [self.tableView reloadData];
}

-(void)getCategories {
    
    self->tableData = [[NSMutableArray alloc] init];
    for (int i=0; i < [self->allTags count]; i++) {
        int cat = [[self->allTags[i] valueForKey:@"isCat"] intValue];
        if (cat > 0) {
            [self->tableData addObject:self->allTags[i]];
        }
    }
    
}

@end
