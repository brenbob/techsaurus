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
#import "AFNetworking.h"
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

    sorted = 1;

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Tech Words";
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark data methods

-(void)requestTerms:(NSString*)tag
{
    
    NSString *termsUrl = [Common getUrl:@"termsUrl" :tag];
    NSURL *url = [NSURL URLWithString:termsUrl];
    NSLog(@"url = %@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _allTerms = [responseObject objectForKey:@"Terms"];
        appDelegate.allTerms = _allTerms; // store in appdelegate for use in other views
        [self getSections:_allTerms];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
}

-(NSArray* )getSections:(NSArray*)allItems
{
    _sections = nil;
     NSMutableArray *sections = [[NSMutableArray alloc] init];

     int sectionStart = 0;
     int sectionCount = 1;
     NSString *tmpTitle = nil;
     NSString *sectionTitle = nil;
        
     for (int i=0; i < [allItems count]; i++) {
     // get first letter of term as section header

         tmpTitle = [[[allItems[i] valueForKey:@"title"] substringToIndex:1] uppercaseString];
         if ([tmpTitle isEqualToString:sectionTitle]) {
             // section has 2 or more items, so increment counter
             sectionCount++;
         } else  {
             // populate sections array and reset counters
             if ([sectionTitle length] > 0) {
                 [sections addObject:[NSArray arrayWithObjects:sectionTitle, [NSNumber numberWithInteger:sectionStart], [NSNumber numberWithInteger:sectionCount], nil]];
             }
             sectionStart = i;
             sectionTitle = tmpTitle;
             sectionCount = 1;
             
         }
         if (i == [allItems count]-1) {
             // last item in parent array
             [sections addObject:[NSArray arrayWithObjects:sectionTitle, [NSNumber numberWithInteger:sectionStart], [NSNumber numberWithInteger:sectionCount], nil]];
         }

     }
     _sections = sections;
    return _sections;
    
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
    return [_sections count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, [[UIScreen mainScreen] bounds].size.width-40, 20.0)];
    header.font = [UIFont systemFontOfSize:10.0];
    header.textAlignment = NSTextAlignmentCenter ;
    header.backgroundColor = [UIColor lightGrayColor];
    header.textColor = [UIColor whiteColor];
    header.text = [_sections objectAtIndex:section][0];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSNumber *)[_sections objectAtIndex:section][2] intValue];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
        
	}
    // add indexPath.row to starting index of current section
    int originalIndex = [(NSNumber *)[_sections objectAtIndex:indexPath.section][1] intValue] + indexPath.row;
    
    NSArray *item = [_allTerms objectAtIndex:originalIndex];
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int originalIndex = [(NSNumber *)[_sections objectAtIndex:indexPath.section][1] intValue] + indexPath.row;
    NSArray *object = [_allTerms objectAtIndex:originalIndex];
    self.detailViewController.detailItem = object;
    [self performSegueWithIdentifier: @"showDetail" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        self.title = @"Back";
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int originalIndex = [(NSNumber *)[_sections objectAtIndex:indexPath.section][1] intValue] + indexPath.row;
        NSArray *object = [_allTerms objectAtIndex:originalIndex];
        [[segue destinationViewController] setDetailItem:object];
    }
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
    NSArray *sortedArray = [_allTerms sortedArrayUsingDescriptors:sortDescriptors];
    _allTerms = sortedArray;
    [self.tableView reloadData];
}


@end
