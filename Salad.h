//
//  Salad.h
//  techlingo
//
//  Created by Brenden West on 6/30/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@class AppDelegate;

@interface Salad : UIViewController

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITextView *output;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnFormat;
@property (nonatomic, strong) IBOutlet UIButton *btnReload;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;

- (IBAction)makeSalad;
- (IBAction)shareItem;

@end
