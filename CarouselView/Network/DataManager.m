//
//  DataManager.m
//  CarouselView
//
//  Created by Dan Deng on 11/4/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@end

@implementation DataManager

static NSString * const vehicleListUrl = @"https://api.uber.com/v1/products?latitude=40.7127&longitude=-74.0059&server_token=9OVN_yz8N-FvD1Fz1nlZfcPQhsXB9BDfRd020Igc";

@synthesize delegate;

-(void)searchVehicles {
    NSURL *url = [NSURL URLWithString: vehicleListUrl];
    if (!url) {
        NSAssert(url != nil, @"Invalid url");
        return;
    }
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (!httpResponse || httpResponse.statusCode < 200 || httpResponse.statusCode > 299) {
            NSLog(@"%ld", httpResponse.statusCode);
            return;
        }
        if (!data) {
            NSLog(@"Network request returned no data");
            return;
        }
        NSError *jsonSerializationError = nil;
        NSDictionary *vehicleData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonSerializationError];
        if (jsonSerializationError) {
            NSLog(@"%@", jsonSerializationError.localizedDescription);
            return;
        }
        if (!vehicleData) {
            NSLog(@"Error serializing data");
            return;
        }
        NSArray* vehicles = [self parseVehicleData:vehicleData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateSearchResults:vehicles];
        });
    }];
    [dataTask resume];
}

-(NSArray *)parseVehicleData:(NSDictionary*)data {
    NSArray *products = [data objectForKey:@"products"];
    if (!products) {
        return [NSArray array];
    }
    NSMutableArray *vehicles = [NSMutableArray array];
    for (NSDictionary *product in products) {
        if (!product) {
            continue;
        }
        NSString *imageUrl = [product objectForKey:@"image"];
        NSString *displayName = [product objectForKey:@"display_name"];
        NSNumber *capacity = [product objectForKey:@"capacity"];
        if (!imageUrl || !displayName || !capacity) {
            continue;
        }
        Vehicle *vehicle = [[Vehicle alloc]
                            initWithDisplayName:displayName
                            capacity:capacity.integerValue
                            imageUrl:imageUrl];
        [vehicles addObject:vehicle];
    }
    return vehicles;
}

@end
