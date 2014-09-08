//
//  Terms.h
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate, DetailViewController;

@interface Terms : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
    int sorted;
    NSMutableArray *searchResults;
    NSArray *allTerms;
    NSArray *sections;

}


@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *btnSortTable;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *uiLoading;
@property IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) DetailViewController *detailViewController;


- (IBAction)sortTable;

@end
