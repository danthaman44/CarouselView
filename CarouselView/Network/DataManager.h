//
//  DataManager.h
//  CarouselView
//
//  Created by Dan Deng on 11/4/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vehicle.h"

@protocol VehicleSearchDelegate <NSObject>

@required
-(void)updateSearchResults:(NSArray *)results;

@optional
-(void)handleError;

@end

@interface DataManager : NSObject

-(void)searchVehicles;

@property (weak, nonatomic) id <VehicleSearchDelegate> delegate;

@end
