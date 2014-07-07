//
//  DetailViewController.h
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "DWTagList.h"

@class AppDelegate, TermsByTagVC, Jobs;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, DWTagListDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UITextView *description;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DWTagList *tagList;
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic, weak) NSString *selectedTag;
@property (nonatomic, weak) NSLayoutConstraint *descriptionHeightConstraint;
@property (strong, nonatomic) TermsByTagVC *termsByTagVC;

@end
