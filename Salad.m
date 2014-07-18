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

NSArray *roles;
NSArray *activity;
NSArray *activity2;
NSArray *roleAdj;
NSArray *prodAdj;
NSArray *coAdj;

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
    [self requestWordLists];
    
}

-(void)requestWordLists
{

    NSString *tagsUrl = [Common getUrl:@"saladUrl" :@""];
    NSURL *url = [NSURL URLWithString:tagsUrl];
    NSLog(@"url = %@",url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        roles = [responseObject objectForKey:@"roles"];
        activity = [responseObject objectForKey:@"activity"];
        activity2 = [responseObject objectForKey:@"activity2"];
        roleAdj = [responseObject objectForKey:@"roleAdj"];
        prodAdj = [responseObject objectForKey:@"prodAdj"];
        coAdj = [responseObject objectForKey:@"coAdj"];
        // generate random text
        [self makeSalad];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
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
