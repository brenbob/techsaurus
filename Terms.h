//
//  Terms.h
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate, DetailViewController;

@interface Terms : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    int sorted;
}


@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *btnSortTable;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSArray *allTerms;
@property (strong, nonatomic) NSArray *sections;

- (IBAction)sortTable;

@end
