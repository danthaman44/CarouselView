//
//  ViewController.h
//  CarouselView
//
//  Created by Dan Deng on 11/3/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarouselCardCell.h"
#import "DataManager.h"
#import "ImageLoader.h"

@interface CarouselViewController : UIViewController<UICollectionViewDataSource,
                                                     UICollectionViewDataSourcePrefetching,
                                                     UICollectionViewDelegate,
                                                     UICollectionViewDelegateFlowLayout,
                                                     UIScrollViewDelegate,
                                                     VehicleSearchDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *carouselCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;

@end
