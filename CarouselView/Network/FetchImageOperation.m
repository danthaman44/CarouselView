//
//  FetchImageOperation.m
//  CarouselView
//
//  Created by Dan Deng on 10/29/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "FetchImageOperation.h"

@interface FetchImageOperation ()

@end

@implementation FetchImageOperation

@synthesize tag;
@synthesize images;
@synthesize urlString;

-(instancetype)initWithUrlString:(NSString *)url tag:(NSInteger)tag images:(NSMutableArray *)images {
    if (self = [super init]) {
        self.tag = tag;
        self.images = images;
        self.urlString = url;
    }
    return self;
}

-(void)main {
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    if (!data) {
        NSLog(@"Failed to fetch image data from %@", self.urlString);
        return;
    }
    UIImage *image = [UIImage imageWithData:data];
    if (!image) {
        NSLog(@"Failed to convert image data to UIImage");
        return;
    }
    [self.images setObject:image atIndexedSubscript:self.tag];
}

@end
