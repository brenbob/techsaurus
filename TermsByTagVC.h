//
//  TermsByTagVC.h
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, DetailViewController;

@interface TermsByTagVC : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsByTag;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *btnSortTable;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSArray *allTerms;
@property (strong, nonatomic) NSString *selectedTag;

- (IBAction)sortTable;

@end
