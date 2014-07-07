//
//  Common.m
//  techlingo
//
//  Created by Brenden West on 7/1/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Common.h"

@implementation Common

- (id) init
{
    self = [super init];
	if (self == [super init]) {
		return self;
	}
	
	return nil;
	
}

+ (UITextView *)formatTextView:(UITextView*)textView :(NSString*)placeholder {
    textView.layer.cornerRadius = 8;
	textView.layer.borderWidth = 1;
	textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textView.text = placeholder;
    textView.textColor = [UIColor darkGrayColor];
    return textView;
}

@end
