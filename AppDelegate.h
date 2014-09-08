//
//  AppDelegate.h
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "GAI.h"


// define value for determining pre-iOS 7 devices
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

// define value to set analytics 'dryRun' and exclude dev traffic from reports
#define DRYRUN YES

//#define DEVAPI 1

//#define JOBS_API_DEV 1

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) NSDictionary *configuration;
@property (strong, nonatomic) NSArray *allTerms;
@property(nonatomic, strong) id<GAITracker> tracker;

- (void)trackPV:(NSString*)screenName;
- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel :(NSNumber*)eventValue;

@end
