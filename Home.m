//
//  Home.m
//  techlingo
//
//  Created by Brenden West on 6/28/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Home.h"
#import "AppDelegate.h"

@implementation Home
@synthesize appDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Tech Lingo";
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

@end
