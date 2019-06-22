//
//  PHPhotoBrowserViewController.m
//  PhotoBrowser
//
//  Created by Lanht on 2019/6/16.
//  Copyright © 2019 lanht. All rights reserved.
//

#import "PHPhotoBrowserViewController.h"
#import <Photos/Photos.h>
/**
 enum PHAssetCollectionType : Int {
 case Album //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
 case SmartAlbum //经由相机得来的相册
 case Moment //Photos 为我们自动生成的时间分组的相册
 }
 
 enum PHAssetCollectionSubtype : Int {
 case AlbumRegular //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
 case AlbumSyncedEvent //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
 case AlbumSyncedFaces //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
 case AlbumSyncedAlbum //做了 AlbumSyncedEvent 应该做的事
 case AlbumImported //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
 case AlbumMyPhotoStream //用户的 iCloud 照片流
 case AlbumCloudShared //用户使用 iCloud 共享的相册
 case SmartAlbumGeneric //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
 case SmartAlbumPanoramas //相机拍摄的全景照片
 case SmartAlbumVideos //相机拍摄的视频
 case SmartAlbumFavorites //收藏文件夹
 case SmartAlbumTimelapses //延时视频文件夹，同时也会出现在视频文件夹中
 case SmartAlbumAllHidden //包含隐藏照片或视频的文件夹
 case SmartAlbumRecentlyAdded //相机近期拍摄的照片或视频
 case SmartAlbumBursts //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
 case SmartAlbumSlomoVideos //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。不过我的 iPad mini 不支持，没法验证。
 case SmartAlbumUserLibrary //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
 case Any //包含所有类型
 }
 */

#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface PHPhotoBrowserViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong ,nonatomic) NSMutableArray *assetCollectionList;
@property (strong ,nonatomic) NSMutableArray *assets;

@end

static NSString *const cellID = @"PHPhotoBrowserCell";

@implementation PHPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        [self getAlbums];
    }];
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
    cell.tag = indexPath.row;
    PHAsset *asset = self.assets[indexPath.row];
    [self showImageInCell:cell index:indexPath.row asset:asset];
    return cell;
}

#pragma mark -
- (void)showImageInCell:(UICollectionViewCell *)cell index:(NSInteger)index asset:(PHAsset *)asset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = NO;
    
    CGFloat imageWidth = (kScreenWidth - 20.f) / 5.5;
    CGSize size = CGSizeMake(imageWidth, imageWidth);
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (cell.tag == index) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
            imageView.image = result;
            [cell.contentView addSubview:imageView];
        }
    }];
}

#pragma mark -
- (void)getAlbums {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *colletion in collectionResult) {
            NSLog(@"Album相册名字--%@",colletion.localizedTitle);
        }
        
        PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        for (PHAssetCollection *colletion in collectionResult1) {
            NSLog(@"SmartAlbum相册名字--%@",colletion.localizedTitle);
            NSArray *assets = [self getAssetFromCollection:colletion];
            [self.assets addObjectsFromArray:assets];
        }
        
        PHFetchResult<PHAssetCollection *> *collectionResult2 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *colletion in collectionResult2) {
            NSLog(@"Moment相册名字--%@",colletion.localizedTitle);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];

        });
    });
}

- (NSArray *)getAssetFromCollection:(PHAssetCollection *)collection {
    NSMutableArray *images = [NSMutableArray array];
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    for (PHAsset *asset in assetResult) {
        if (asset.mediaType != PHAssetMediaTypeImage) continue;
        
        [images addObject:asset];
    }
    return [NSArray arrayWithArray:images];
}

- (NSMutableArray *)assetCollectionList {
    if (!_assetCollectionList) {
        _assetCollectionList = [NSMutableArray array];
    }
    return _assetCollectionList;
}

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

@end
