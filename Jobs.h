//
//  Jobs.h
//  techlingo
//
//  Created by Brenden West on 7/6/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

@interface Jobs : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView	*webView;
@property (nonatomic, strong) NSString	*selectedTag;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobsSites;

- (IBAction)loadJobs:(id)sender;

@end