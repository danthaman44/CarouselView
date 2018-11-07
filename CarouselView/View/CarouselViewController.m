//
//  ViewController.m
//  CarouselView
//
//  Created by Dan Deng on 11/3/18.
//  Copyright © 2018 Dan Deng. All rights reserved.
//

#import "CarouselViewController.h"

@interface CarouselViewController ()

@property (nonatomic, assign) NSInteger currentIndexRow;
@property (nonatomic, strong) NSArray *vehicles;
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ImageLoader *imageLoader;

@end

@implementation CarouselViewController

// MARK: - Constants

static CGFloat const cardSpacing = 10;
static NSInteger const pagingSize = 2;

// MARK: - Properties

// Public
@synthesize carouselCollectionView;
@synthesize nameLabel;
@synthesize capacityLabel;

// Private
@synthesize dataManager;
@synthesize imageLoader;
@synthesize vehicles;
@synthesize currentIndexRow;

// MARK: - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.vehicles = [NSArray array];
        self.imageLoader = [[ImageLoader alloc] init];
        self.dataManager = [[DataManager alloc] init];
        self.dataManager.delegate = self;
        self.currentIndexRow = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set collectionView layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.carouselCollectionView setCollectionViewLayout:flowLayout];

    // Setup collectionView
    self.carouselCollectionView.delegate = self;
    self.carouselCollectionView.dataSource = self;
    self.carouselCollectionView.prefetchDataSource = self;
    [self.carouselCollectionView registerNib:[UINib nibWithNibName:@"CarouselCardCell" bundle:nil] forCellWithReuseIdentifier:@"CarouselCardCell"];

    self.carouselCollectionView.pagingEnabled = YES;
    self.carouselCollectionView.prefetchingEnabled = YES;
    self.carouselCollectionView.showsHorizontalScrollIndicator = NO;
    self.carouselCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.carouselCollectionView.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [dataManager searchVehicles];
}

// MARK: - VehicleSearchDelegate

-(void)updateSearchResults:(NSArray *)results {
    self.vehicles = results;
    [self.carouselCollectionView reloadData];
    [self.carouselCollectionView performBatchUpdates:^{
        // No-op
    } completion:^(BOOL finished) {
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndexRow inSection:0];
        UICollectionViewCell *currentCell = [self.carouselCollectionView cellForItemAtIndexPath:currentIndexPath];
        currentCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1);
    }];
}

// MARK: - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.vehicles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CarouselCardCell *cell = [self.carouselCollectionView dequeueReusableCellWithReuseIdentifier:@"CarouselCardCell" forIndexPath:indexPath];
    if (!cell) {
        return [[CarouselCardCell alloc] init];
    }
    Vehicle* vehicleToDisplay = [self.vehicles objectAtIndex:indexPath.row];
    [self.imageLoader loadImageFromUrl:vehicleToDisplay.imageUrl completion:^(UIImage *image) {
        cell.imageView.image = image;
    }];
    return cell;
}

// MARK: - UICollectionViewDataSourcePrefetching

-(void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.row >= currentIndexRow - pagingSize && indexPath.row <= currentIndexRow + pagingSize) {
            Vehicle* vehicleToDisplay = [self.vehicles objectAtIndex:indexPath.row];
            [self.imageLoader loadImageFromUrl:vehicleToDisplay.imageUrl completion:^(UIImage *image) {}];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        Vehicle* vehicle = [self.vehicles objectAtIndex:indexPath.row];
        [self.imageLoader cancelImageLoadForUrl:vehicle.imageUrl];
    }
}

// MARK: - UICollectionViewDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(carouselCollectionView.bounds.size.width - (4 * cardSpacing),
                      carouselCollectionView.bounds.size.height - (2 * cardSpacing));
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cardSpacing;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(cardSpacing, 2 * cardSpacing, cardSpacing, 2 * cardSpacing);
}

// MARK: - UIScrollViewDelegate

-(void)snapToNextItemIn:(UIScrollView *)scrollView {
    if (scrollView != self.carouselCollectionView) {
        return;
    }
    CGFloat scrollTranslation = [scrollView.panGestureRecognizer translationInView:scrollView.superview].x;
    NSInteger updatedIndexRow = scrollTranslation > 0 ? self.currentIndexRow - 1 : self.currentIndexRow + 1;
    if (updatedIndexRow < 0 || updatedIndexRow >= self.vehicles.count) {
        return;
    }

    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:currentIndexRow inSection:0];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:updatedIndexRow inSection:0];
    UICollectionViewCell *currentCell = [self.carouselCollectionView cellForItemAtIndexPath:currentIndexPath];
    UICollectionViewCell *nextCell = [self.carouselCollectionView cellForItemAtIndexPath:nextIndexPath];

    [UIView animateWithDuration:0.3
         animations:^{
            currentCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            nextCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1);
            [self.carouselCollectionView scrollToItemAtIndexPath:nextIndexPath
                                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                        animated:NO];
        } completion:^(BOOL finished) {
            self.currentIndexRow = updatedIndexRow;
            Vehicle *selectedVehicle = [self.vehicles objectAtIndex:self.currentIndexRow];
            self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", selectedVehicle.displayName];
            self.capacityLabel.text = [NSString stringWithFormat:@"Capacity: %ld", selectedVehicle.capacity];
        }];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self snapToNextItemIn:scrollView];
}

@end
