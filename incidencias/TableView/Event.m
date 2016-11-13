//
//  Car.m
//  AddItemTableViewDemo
//
//  Created by Arthur Knopper on 15-06-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import "Event.h"

@implementation Event

- (id)initWithName:(NSString *)brandName;
{
    self = [super init];
    
    if (self) {
        _brandName = brandName;
    }
    
    return self;
}

@end
