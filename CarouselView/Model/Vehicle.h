//
//  Vehicle.h
//  CarouselView
//
//  Created by Dan Deng on 11/4/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vehicle : NSObject

@property (strong, atomic) NSString *imageUrl;
@property (strong, atomic) NSString *displayName;
@property (assign, atomic) NSInteger capacity;

-(instancetype)initWithDisplayName:(NSString *)displayName capacity:(NSInteger)capacity imageUrl:(NSString *)imageUrl;

@end
