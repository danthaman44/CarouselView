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
static CGFloat const animationDuration = 0.3;
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

    // Setup scrollView
    self.carouselCollectionView.prefetchingEnabled = YES;
    self.carouselCollectionView.showsHorizontalScrollIndicator = NO;
    self.carouselCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.carouselCollectionView.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [dataManager searchVehicles];
}

-(void)displayVehicleData {
    if (vehicles.count == 0) {
        self.nameLabel.text = @"No data";
        self.capacityLabel.text = @"No data";
    } else {
        Vehicle *selectedVehicle = [self.vehicles objectAtIndex:self.currentIndexRow];
        self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", selectedVehicle.displayName];
        self.capacityLabel.text = [NSString stringWithFormat:@"Capacity: %ld", selectedVehicle.capacity];
    }
}

// MARK: - VehicleSearchDelegate

-(void)updateSearchResults:(NSArray *)results {
    self.vehicles = results;
    [self.carouselCollectionView reloadData];
    [self.carouselCollectionView performBatchUpdates:^{
    } completion:^(BOOL finished) {
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndexRow inSection:0];
        UICollectionViewCell *currentCell = [self.carouselCollectionView cellForItemAtIndexPath:currentIndexPath];
        currentCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1);
    }];
}

// MARK: - CarouselCardDelegate

-(void)hideCell:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.carouselCollectionView indexPathForCell:cell];
    if (indexPath.row < 0 || indexPath.row >= self.vehicles.count) {
        return;
    }
    [UIView animateWithDuration:animationDuration animations:^{
        // First fade the cell away
        cell.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Update the data source before updating collectionView UI
        NSMutableArray *updatedVehicles = [self.vehicles mutableCopy];
        [updatedVehicles removeObjectAtIndex:indexPath.row];
        self.vehicles = updatedVehicles;
        // Animate the cell deletion alongside the entry of the replacement cell
        __block NSIndexPath *replacementIndexPath = indexPath; // indexPath of the item that replaces the deleted item
        [UIView transitionWithView:self.carouselCollectionView duration:animationDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
            NSArray *indexPathsToDelete = @[[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [self.carouselCollectionView deleteItemsAtIndexPaths:indexPathsToDelete];
            replacementIndexPath = indexPath.row == self.vehicles.count ? [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0] : indexPath;
            if (replacementIndexPath.row >= 0 && replacementIndexPath.row < self.vehicles.count) {
                UICollectionViewCell *replacementCell = [self.carouselCollectionView cellForItemAtIndexPath:replacementIndexPath];
                replacementCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1);
            }
        } completion:^(BOOL finished) {
            self.currentIndexRow = replacementIndexPath.row;
            [self displayVehicleData];
        }];
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
    cell.delegate = self;
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

    [UIView animateWithDuration:animationDuration
         animations:^{
            currentCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            nextCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1);
            [self.carouselCollectionView scrollToItemAtIndexPath:nextIndexPath
                                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                        animated:NO];
        } completion:^(BOOL finished) {
            self.currentIndexRow = updatedIndexRow;
            [self displayVehicleData];
        }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self snapToNextItemIn:scrollView];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self snapToNextItemIn:scrollView];
}

@end
