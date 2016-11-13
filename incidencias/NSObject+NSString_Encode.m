//
//  NSObject+NSString_Encode.m
//  incidencias
//
//  Created by PLEASE on 16/02/16.
//  Copyright © 2016 zaltan nyhether. All rights reserved.
//

#import "NSObject+NSString_Encode.h"

@implementation NSString (encode)
- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding)));
}  
@end