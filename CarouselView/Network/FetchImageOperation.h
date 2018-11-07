//
//  FetchImageOperation.h
//  CarouselView
//
//  Created by Dan Deng on 10/29/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FetchImageOperation : NSOperation

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSString *urlString;
@property (atomic, strong) NSMutableArray *images;

-(instancetype)initWithUrlString:(NSString *)url tag:(NSInteger)tag images:(NSMutableArray *)images;

@end
