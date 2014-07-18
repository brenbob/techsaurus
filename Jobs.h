//
//  Jobs.h
//  techlingo
//
//  Created by Brenden West on 7/6/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate;

@interface Jobs : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UITableView	*tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobSite;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uiLoading;

@property (nonatomic, strong) NSString *searchTerm;

@property (nonatomic, strong) NSMutableArray *jobsAll;
@property (nonatomic, strong) NSArray *jobsForSite;

- (IBAction)switchJobSite:(id)sender;
- (IBAction)loadJobAgent;

@end