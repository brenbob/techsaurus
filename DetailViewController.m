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


#define kMaxHeight 100.f

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

- (void)configureTextView
{
    // Update the user interface for the detail item.
    if (_detailItem) {
        _description.text = [self.detailItem valueForKey:@"description"];
        
//      _description.text = @"Summertime and the Coding's Easy: We're in Van Vorst, Amazon has said they'll turn on the air conditioning, and there's fun to be had. Remember, parking is $2 **all day** at the 321 Terry and 550 Terry garages, so make a day of Downtown after Dojo";
/*
        [_description invalidateIntrinsicContentSize];
        CGSize sizeThatFitsTextView = [_description sizeThatFits:CGSizeMake(_description.frame.size.width, MAXFLOAT)];
        _descriptionHeightConstraint.constant = ceilf(sizeThatFitsTextView.height);
        [_description layoutIfNeeded];
*/
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.detailItem valueForKey:@"title"];

    _descriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.description attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100.0];

    [_description addConstraint:_descriptionHeightConstraint];
    [Common formatTextView:_description :nil];
    [self configureTextView];
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

    // split tags string into array for rendering
    // add current item to tag list
    NSMutableArray *tagsArray = [[[self.detailItem valueForKey:@"tags"] componentsSeparatedByString:@","] mutableCopy];
    [tagsArray insertObject:[self.detailItem valueForKey:@"title"] atIndex:0];
    [self renderTags:tagsArray];

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
        [[segue destinationViewController] setSelectedTag:self.title];
    }
}

- (void)renderTags:(NSArray *)tagsArray {
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10.0f, 180.0f, self.view.bounds.size.width-40.0f, 50.0f)];
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
    return @"More info:";
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
