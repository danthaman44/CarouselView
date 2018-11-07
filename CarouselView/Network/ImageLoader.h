//
//  ImageLoader.h
//  CarouselView
//
//  Created by Dan Deng on 10/29/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FetchImageOperation.h"

@interface ImageLoader : NSObject

+(NSOperationQueue*)backgroundQueue;

-(void)loadImageFromUrl:(NSString*)url completion:(void(^)(UIImage*))completionBlock;

-(void)cancelImageLoadForUrl:(NSString*)url;

@end
