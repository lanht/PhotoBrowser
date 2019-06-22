//
//  ALPhotoBrowerViewController.m
//  PhotoBrowser
//
//  Created by Lanht on 2019/6/20.
//  Copyright © 2019 lanht. All rights reserved.
//

#import "ALPhotoBrowerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending )

@interface ALPhotoBrowerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong ,nonatomic) NSMutableArray *assets;

/**
 The lifetimes of objects you get back from a library instance are tied to the lifetime of the library instance.
 通过ALAssetsLibrary对象获取的其他对象只在该ALAssetsLibrary对象生命期内有效，若ALAssetsLibrary对象被销毁，则其他从它获取的对象将不能被访问，否则有会错误。
 */
@property (strong ,nonatomic) ALAssetsLibrary *library; //必须保活

@end

static NSString *const cellID = @"ALPhotoBrowserCell";

@implementation ALPhotoBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
    // 判断授权状态
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        if (status != PHAuthorizationStatusAuthorized) return;
//
//        [self getAlbums];
//    }];
    [self getAlbums];
}

- (void)setUpView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5.f;
    layout.minimumInteritemSpacing = 5.f;
    layout.itemSize = CGSizeMake((kScreenWidth - 20.f) / 3.f, (kScreenWidth - 20.f) / 3.f);
    [self.collectionView setCollectionViewLayout:layout];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    ALAsset *asset = self.assets[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.contentView.bounds];
    imageView.image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark -


#pragma mark -
- (void)getAlbums {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [self.assets addObject:result];
                };
            }];
            
            [self.collectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"获取相册照片失败---%@",error.localizedDescription);
    }];
    self.library = library;
}

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

@end
