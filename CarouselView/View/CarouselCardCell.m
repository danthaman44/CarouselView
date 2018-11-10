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

    // setup button
    self.hideButton.layer.cornerRadius = 6.0;
    [self.hideButton addTarget:self action:@selector(didTapHideButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.delegate = nil;
}

-(void)didTapHideButton:(UIButton*)button {
    [self.delegate hideCell:self];
}

@end
