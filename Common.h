//
//  Common.h
//  techlingo
//
//  Created by Brenden West on 7/1/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

- (id) init;

+ (UITextView *)formatTextView:(UITextView*)textView :(NSString*)placeholder;

@end
