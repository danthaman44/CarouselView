//
//  CarouselCardCell.m
//  CarouselView
//
//  Created by Dan Deng on 11/3/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "CarouselCardCell.h"

@implementation CarouselCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.lightGrayColor;
    self.layer.cornerRadius = 6.0;
}

@end
