//
//  ImageLoader.m
//  CarouselView
//
//  Created by Dan Deng on 10/29/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "ImageLoader.h"

@interface ImageLoader ()

@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) NSMutableDictionary *operationForUrl;

@end

@implementation ImageLoader

@synthesize imageCache;

+(NSOperationQueue*)backgroundQueue {
    static NSOperationQueue *operationQueue = nil;
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return operationQueue;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.countLimit = 20;
    }
    return self;
}

-(void)loadImageFromUrl:(NSString*)url completion:(void(^)(UIImage*))completionBlock {
    UIImage *cachedImage = [self.imageCache objectForKey:url];
    if (cachedImage) {
        completionBlock(cachedImage);
    }
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:1];
    FetchImageOperation *fetchOperation = [[FetchImageOperation alloc]
                                           initWithUrlString:url
                                           tag:0
                                           images:images];
    fetchOperation.name = url; // use the url as the operation's unique identifier, useful for debugging
    [self.operationForUrl setObject:fetchOperation forKey:url]; // track the operation by putting it into the dict
    [fetchOperation setCompletionBlock:^{
        UIImage *image = [images objectAtIndex:0];
        [self.imageCache setObject:image forKey:url]; // cache the image
        [self.operationForUrl removeObjectForKey:url]; // stop tracking the operation
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image);
        });
    }];
    [ImageLoader.backgroundQueue addOperation:fetchOperation];
}

-(void)cancelImageLoadForUrl:(NSString*)url {
    NSOperation *pendingOperation = [self.operationForUrl objectForKey:url];
    if (pendingOperation) {
        [pendingOperation cancel];;
    }
}

@end
