//
//  Common.m
//  techlingo
//
//  Created by Brenden West on 7/1/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"

@implementation Common

- (id) init
{
    self = [super init];
	if (self == [super init]) {
		return self;
	}
	
	return nil;
	
}

+ (NSString *)getUrl:(NSString*)key :(NSString*)tag {

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *urlString = [appDelegate.configuration objectForKey:key];
    if (tag != nil) {
        tag = [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    } else {
        tag = @"";
    }
    urlString = [urlString stringByReplacingOccurrencesOfString:@"<tag>" withString:tag];
    
#ifdef DEVAPI
    urlString = [NSString stringWithFormat:@"%@%@",[appDelegate.configuration objectForKey:@"apiDomainDev"],urlString];
#else
    urlString = [NSString stringWithFormat:@"%@%@",[appDelegate.configuration objectForKey:@"apiDomainProd"],urlString];
#endif

    return urlString;

}

+ (UITextView *)formatTextView:(UITextView*)textView :(NSString*)placeholder {
    textView.layer.cornerRadius = 8;
	textView.layer.borderWidth = 1;
	textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textView.text = placeholder;
    textView.textColor = [UIColor darkGrayColor];
    return textView;
}

/** return short date from date **/
+ (NSString *)stringFromDate:(NSDate*)tmpDate {
	NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc ] init];
    [shortDateFormatter setLocale:[NSLocale currentLocale]];
	[shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
	if (!tmpDate) { tmpDate = [NSDate date]; }
    
    NSString *dateString = [shortDateFormatter stringFromDate:tmpDate];
    return dateString;
    
}

/** return short date from string **/
+ (NSString *)getShortDate:(NSString*)tmpDate {
	
	NSDateFormatter *outputFormat = [[NSDateFormatter alloc ] init];
	[outputFormat setDateStyle:NSDateFormatterShortStyle];
    NSString *retString = [outputFormat stringFromDate:[NSDate date]];
	
	if ([tmpDate length] > 0 && ![tmpDate isEqual:@"(null)"]) {
		
		NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
		[inputFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
		[inputFormat setLenient:YES];
        
		// date format from web service "2014-06-30T00:58:05.000Z"
        [inputFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		NSDate *formattedDate = [inputFormat dateFromString:tmpDate];
		if (formattedDate == nil) { // try system format
			// 2010-04-06 00:00:00 -0700
			[inputFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZZ"];
			formattedDate = [inputFormat dateFromString:tmpDate];
            NSLog(@"system format = %@",formattedDate);
		}
		if (formattedDate != nil) { // return current date
			retString = [outputFormat stringFromDate:formattedDate];
		}
        
	} else { // no date input
        retString = [outputFormat stringFromDate:[NSDate date]];
	}
    return retString;
}

@end
