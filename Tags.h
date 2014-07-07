//
//  Tags.h
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate, DetailViewController;

@interface Tags : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *tableData;
    NSArray *allTags;
    int sorted;
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnSwitchTable;
@property (nonatomic, strong) IBOutlet UIButton *btnSortTable;
@property (strong, nonatomic) DetailViewController *detailViewController;

- (IBAction)sortTable;

@end
