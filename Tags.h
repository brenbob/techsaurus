//
//  Tags.h
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate, DetailViewController;

@interface Tags : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
    int sorted;
    NSMutableArray *searchResults;
    NSArray *allTerms;
    NSArray *sections;
    NSMutableArray *categories;
    NSArray *tableData; // tmp table to populate tableView w/ either categories or all terms
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnSwitchTable;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *btnSortTable;
@property IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) DetailViewController *detailViewController;

- (IBAction)sortTable;

@end
