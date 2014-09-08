//
//  AppDelegate.m
//  techlingo
//
//  Created by Brenden West on 6/23/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "AppDelegate.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

/** Google Analytics configuration constants **/
/** Other settings in appconfig.plist **/
#ifdef DRYRUN
    static BOOL const kGaDryRun = YES;
#else
    static BOOL const kGaDryRun = NO;
#endif


@implementation AppDelegate
@synthesize configuration = _configuration;
@synthesize allTerms = _allTerms;


#pragma mark setup

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // load values from appconfig.plist
    _configuration = [self configuration];

    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut = ![_configuration objectForKey:@"kAllowTracking"];
    
    // Initialize Google Analytics with a N-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = (int)[_configuration objectForKey:@"kGaDispatchPeriod"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] setDryRun:kGaDryRun];
    // Set the log level to verbose.
        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[_configuration objectForKey:@"kGaPropertyId"]];


    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (NSDictionary *)configuration
{
    if (_configuration == nil)
    {
        NSMutableDictionary *configuration = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // init configuration map
        NSDictionary *configMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"jobAgentUrl",             @"jobAgentUrl",
                                   @"kGaPropertyId",           @"kGaPropertyId",
                                   @"kGaDispatchPeriod",       @"kGaDispatchPeriod",
                                   @"kAllowTracking",          @"kAllowTracking",
                                   @"adUnitID",                @"adUnitID",
                                   @"apiDomainDev",            @"apiDomainDev",
                                   @"apiDomainProd",           @"apiDomainProd",
                                   @"jobsApiDomainDev",        @"jobsApiDomainDev",
                                   @"jobsApiDomainProd",       @"jobsApiDomainProd",
                                   @"termsUrl",                @"termsUrl",
                                   @"tagsUrl",                 @"tagsUrl",
                                   @"categoriesUrl",           @"categoriesUrl",
                                   @"trendsUrl",               @"trendsUrl",
                                   @"saladUrl",                @"saladUrl",
                                   @"resourceLinks",           @"resourceLinks",
                                   @"simplyHiredUrl",          @"simplyHiredUrl",
                                   @"jobAgentUrl",             @"jobAgentUrl",
                                   @"aboutUrl",                @"aboutUrl",
                                   nil];
        
        
        // loading configuration from stored plist
        for (NSString *key in configMap.allKeys)
        {
            id object = [userDefaults objectForKey:key];
            if (object != nil)
            {
                [configuration setObject:object forKey:key];
            }
        }

        // loading the rest of configuration from default plist
        if (configuration.allKeys.count < configMap.allKeys.count)
        {
            NSString *defaultConfFile = [[NSBundle mainBundle] pathForResource:@"appconfig" ofType:@"plist"];
            NSDictionary *defaultConfig = [NSDictionary dictionaryWithContentsOfFile:defaultConfFile];
            for (NSString *key in configMap.allKeys)
            {

                id defaultObject = [defaultConfig objectForKey:[configMap objectForKey:key]];
                id storedObject = [configuration objectForKey:key];
                if (storedObject == nil && defaultObject != nil)
                {
                    [configuration setObject:defaultObject forKey:key];
                    [userDefaults setObject:defaultObject forKey:key];
                }
            }
            
            [userDefaults synchronize];
        }

        _configuration = configuration;
    }
    
    return _configuration;
}

#pragma mark log data to Google Analytics

- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel :(NSNumber*)eventValue
{
    
    // Google Analytics v3
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];
    
    if (eventCategory != nil) {
        // Send category (params) with screen hit
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventCategory     // Event category (required)
                                                              action:eventAction  // Event action (required)
                                                               label:eventLabel          // Event label
                                                               value:eventValue] build]];    // Event value
    }
    
    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];
}

- (void)trackPV:(NSString*)screenName
{
    
    // Google Analytics v3
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];
    
    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];
    
}



#pragma mark Exit

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




@end
