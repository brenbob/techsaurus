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
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *uiLoading;
@property (nonatomic, weak) IBOutlet UITextField *searchTerm;
@property (nonatomic, weak) IBOutlet UITextField *searchLocation;
@property (nonatomic, strong) IBOutlet UIButton *btnSimplyHired;
@property (nonatomic, strong) IBOutlet UIButton *btnJobAgent;

@property (nonatomic, weak) NSString *keyword;
@property (nonatomic, strong) NSMutableArray *salaries;

- (IBAction)requestJobs:(id)sender;
- (IBAction)linkToSite:(id)sender;

@end