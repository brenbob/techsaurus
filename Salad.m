//
//  Salad.m
//  techlingo
//
//  Created by Brenden West on 6/30/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Salad.h"
#import "AppDelegate.h"
#import "Common.h"

@interface Salad ()

@end

@implementation Salad
@synthesize appDelegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Word Salad";
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [Common formatTextView:self.output :nil];
    
    // generate random text
    [self makeSalad];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)getRandom:(int)max {
    return arc4random() % max;
}

- (IBAction)makeSalad {

    NSArray *roles = @[@"developer",@"designer",@"tester",@"SDET",@"DevOps engineer",@"DB admin",@"architect"];
    NSArray *activity = @[@"quality",@"software",@"creative design",@"cloud",@"systems",@"database"];
    NSArray *activity2 = @[@"engineering",@"design",@"delivery",@"architecting",@"specification",@"management"];
    
    NSArray *roleAdj = @[@"rockstar",@"ninja",@"guru",@"extremely talented",@"fun-loving",@"flexible", @"passionate",@"detail oriented",@"creative",@"driven",@"motivated",@"tenacious",@"street-smart",@"intelligent", @"junior", @"experienced", @"dynamic", @"fanatical"];
    NSArray *prodAdj = @[@"scalable",@"bleeding-edge",@"modern",@"juicy",@"world-class",@"unique",@"proven", @"high performance", @"responsive", @"stunning", @"mission-critical", @"robust", @"secure"];
    NSArray *coAdj = @[@"leading",@"disruptive",@"revolutionary",@"mobile",@"early-stage startup",@"fantastic",@"amazing",@"dominant",@"fast-growing",@"exciting",@"well-funded",@"collaborative"];
    
    // get random item from each array
    NSString *company = [NSString stringWithFormat:@"%@, %@",[coAdj objectAtIndex:[self getRandom:[coAdj count]]], [coAdj objectAtIndex:[self getRandom:[coAdj count]]]];
    NSString *company2 = [coAdj objectAtIndex:[self getRandom:[coAdj count]]];

    NSString *activityStr = [NSString stringWithFormat:@"%@ %@",[activity objectAtIndex:[self getRandom:[activity count]]], [activity2 objectAtIndex:[self getRandom:[activity2 count]]]];

    NSString *roleDesc = [NSString stringWithFormat:@"%@, %@",[roleAdj objectAtIndex:[self getRandom:[roleAdj count]]], [roleAdj objectAtIndex:[self getRandom:[roleAdj count]]]];
    NSString *role = [roles objectAtIndex:[self getRandom:[roles count]]];
    NSString *prod = [prodAdj objectAtIndex:[self getRandom:[prodAdj count]]];
    NSString *skills = [NSString stringWithFormat:@"%@, %@, %@,  %@, and %@",[[appDelegate.allTerms objectAtIndex:[self getRandom:[appDelegate.allTerms count]]] valueForKey:@"title"], [[appDelegate.allTerms objectAtIndex:[self getRandom:[appDelegate.allTerms count]]] valueForKey:@"title"], [[appDelegate.allTerms objectAtIndex:[self getRandom:[appDelegate.allTerms count]]] valueForKey:@"title"], [[appDelegate.allTerms objectAtIndex:[self getRandom:[appDelegate.allTerms count]]] valueForKey:@"title"], [[appDelegate.allTerms objectAtIndex:[self getRandom:[appDelegate.allTerms count]]] valueForKey:@"title"]];
    
    // 1 role, 2 role adjs, 2 co adjs, 1 prod, 4 skills,
    
    if ([_btnFormat selectedSegmentIndex] == 0) {
        _output.text = [NSString stringWithFormat:@"We are a %@ company looking for a %@ %@ with passion for building %@ products and desire to be part of a %@ venture. Desired skills - %@",company, roleDesc, role, prod, company2, skills];
    } else {
        _output.text = [NSString stringWithFormat:@"%@ %@ with %i years of experience delivering %@ projects. Skilled in all phases of %@; expert in %@.",roleDesc, role, [self getRandom:20], prod, activityStr, skills];
    }
    
}

#pragma mark - actions

- (IBAction)shareItem {
    
    NSString *postText = _output.text;
    
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];
    
    
    [activityController setValue:[NSString stringWithFormat:@"Tech Terms - random %i", [_btnFormat selectedSegmentIndex]] forKey:@"subject"];
    
    // Removed un-needed activities
    activityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypePostToWeibo,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeMessage,
                                                UIActivityTypeAssignToContact,
                                                nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
    
}


@end
