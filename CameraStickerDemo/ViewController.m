//
//  ViewController.m
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/4.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>

#import "SKSticker.h"
#import "SKStickerFilter.h"

@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) SKStickerFilter *stickerFilter;

@property (nonatomic, copy) NSArray<SKSticker *> *stickers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    
    self.stickerFilter = [SKStickerFilter new];
    [self.videoCamera addTarget:self.stickerFilter];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    
    [self.stickerFilter addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    [SKStickersManager loadStickersWithCompletion:^(NSArray<SKSticker *> *stickers) {
        self.stickers = stickers;
        self.stickerFilter.sticker = [stickers firstObject];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 在这里做人脸的检测
    
    // 使用假数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fake_points" ofType:@"json"];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                     options:0
                                                       error:nil];
    
    NSMutableArray *faces = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSArray *ele in arr) {
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:ele.count];
        for (NSDictionary *dic in ele) {
            CGPoint point = CGPointMake([dic[@"x"] floatValue], [dic[@"y"] floatValue]);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        
        [faces addObject:points];
    }
    
    self.stickerFilter.faces = faces;
}

@end
