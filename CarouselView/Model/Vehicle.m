//
//  Vehicle.m
//  CarouselView
//
//  Created by Dan Deng on 11/4/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle

@synthesize displayName;
@synthesize capacity;
@synthesize imageUrl;

-(instancetype)initWithDisplayName:(NSString *)displayName capacity:(NSInteger)capacity imageUrl:(NSString *)imageUrl {
    self = [super init];
    if (self) {
        self.displayName = displayName;
        self.capacity = capacity;
        self.imageUrl = imageUrl;
    }
    return self;
}

@end
