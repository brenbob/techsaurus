//
//  DetailViewController.m
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "TermsByTagVC.h"
#import "Jobs.h"
#import "Common.h"


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.detailItem valueForKey:@"title"];
    [Common formatTextView:_description :nil];
    
    if (_detailItem) {
        _description.text = [self.detailItem valueForKey:@"description"];
    }
    
    // populate resources table
    _resources = [[NSMutableArray alloc] init];
    [_resources addObjectsFromArray:[self.detailItem objectForKey:@"resources"]];
    [_resources addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"link", @"Jobs", @"title", nil]];
    [_resources addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"http://www.quora.com/search?q=%@",self.title], @"link", @"Quora", @"title", nil]];
    
    if (_resources) {
        _tableView.dataSource = self;
        [_tableView reloadData];
        _tableView.hidden = NO;
    } else {
        _tableView.hidden = YES;
    }

    
    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space
    }

    // create a custom navigation bar button for 'share' action
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItem)];
    
	rightBarButtonItem.title = NSLocalizedString(@"STR_SHARE", nil);
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;

}

- (void)viewWillAppear:(BOOL)animated
{
    // Split related tags into an array for rendering
    if (![[self.detailItem valueForKey:@"tags"] isEqualToString:@""]) {
        NSMutableArray *tagsArray = [[[self.detailItem valueForKey:@"tags"] componentsSeparatedByString:@","] mutableCopy];
        [self renderTags:tagsArray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tag methods

- (void)selectedTag:(NSString *)tagName{
    _selectedTag = tagName;
    [self performSegueWithIdentifier: @"showByTag" sender: self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showByTag"]) {
        [[segue destinationViewController] setSelectedTag:_selectedTag];
    } else  if ([[segue identifier] isEqualToString:@"showJobs"]) {
        [[segue destinationViewController] setSearchTerm:self.title];
    }
}

- (void)renderTags:(NSArray *)tagsArray {
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10.0f, 207.0f, self.view.bounds.size.width-40.0f, 50.0f)];
    [_tagList setAutomaticResize:YES];
    [_tagList setTags:tagsArray];
    [_tagList setTagDelegate:self];

    // Customisation
    [_tagList setCornerRadius:4.0f];
    [_tagList setBorderColor:[UIColor lightGrayColor].CGColor];
    [_tagList setBorderWidth:1.0f];

    [self.view addSubview:_tagList];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resources.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Resources:";
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
        
	}
    
    NSArray *item = [_resources objectAtIndex:indexPath.row];
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *aItem = _resources[indexPath.row];
    
    if ([[aItem valueForKey:@"title"] isEqualToString:@"Jobs"]) {
        [self performSegueWithIdentifier: @"showJobs" sender: self];
    } else if ([[aItem valueForKey:@"link"] length] > 0) {
        // item has a link
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[aItem valueForKey:@"link"]]];
    }
}



#pragma mark - actions

- (void)shareItem {
    
    NSString *postText = [NSString stringWithFormat:@"%@ : %@\nTags : %@", self.title, self.description.text, [self.detailItem valueForKey:@"tags"]];
    
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];
    
    
    [activityController setValue:[NSString stringWithFormat:@"Tech Term - %@",self.title] forKey:@"subject"];
    
    // Removed un-needed activities
    activityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypePostToWeibo,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeMessage,
                                                UIActivityTypeAssignToContact,
                                                nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];

}


@end
