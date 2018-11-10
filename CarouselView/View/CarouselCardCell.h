//
//  CarouselCardCell.h
//  CarouselView
//
//  Created by Dan Deng on 11/3/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarouselCardDelegate

@required
-(void)hideCell:(UICollectionViewCell*)cell;

@end

@interface CarouselCardCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) id <CarouselCardDelegate> delegate;

@end
