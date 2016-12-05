//
//  SKSticker.m
//  PLMediaStreamingKitDemo
//
//  Created by Sinkup on 2016/10/14.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKSticker.h"


@interface SKStickerItem ()

/**
 计数器
 */
@property (nonatomic) NSTimeInterval accumulator;

@end

@implementation SKStickerItem
{
    NSArray *_imageFileURLs;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _type = [[dict objectForKey:@"type"] intValue];
        _triggerType = [[dict objectForKey:@"triggerType"] intValue];
        
        _alignPosition = [[dict objectForKey:@"alignPos"] intValue];
        
        _dir = [dict objectForKey:@"folder"];
        _count = [[dict objectForKey:@"frames"] intValue];
        
        _frameDuration = [[dict objectForKey:@"frameDuration"] doubleValue] / 1000.;
        _width = [[dict objectForKey:@"width"] floatValue];
        _height = [[dict objectForKey:@"height"] floatValue];
        
        _alignIndexes = [dict objectForKey:@"alignIndexes"];
        _scaleWidth = [[dict objectForKey:@"scaleWidth"] floatValue];
        _scaleHeight = [[dict objectForKey:@"scaleHeight"] floatValue];
        _offsetX = [[dict objectForKey:@"offsetX"] floatValue];
        _offsetY = [[dict objectForKey:@"offsetY"] floatValue];
        
        _triggered = NO;
        _currentFrameIndex = 0;
        _loopCountdown = NSUIntegerMax;
        _accumulator = 0.;
    }
    
    return self;
}

- (NSUInteger)nextFrameIndexForInterval:(NSTimeInterval)interval
{
    // 此处参考了FLAnimatedImage加载GIF的做法
    if (self.loopCountdown == 0) {
        return self.currentFrameIndex;
    }
    
    NSUInteger nextFrameIndex = self.currentFrameIndex;
    self.accumulator += interval;
    
    while (self.accumulator > self.frameDuration) {
        self.accumulator -= self.frameDuration;
        nextFrameIndex++;
        if (nextFrameIndex >= self.count) {
            // If we've looped the number of times that this animated image describes, stop looping.
            self.loopCountdown--;
            
            if (self.loopCountdown == 0) {
                nextFrameIndex = self.count - 1;
                break;
            } else {
                nextFrameIndex = 0;
            }
        }
    }
    
    return nextFrameIndex;
}

- (UIImage *)imageAtIndex:(NSUInteger)index
{
    if (_imageFileURLs.count <= 0) {
        [self _loadImages];
    }
    
    if (index >= _imageFileURLs.count) {
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:[[_imageFileURLs objectAtIndex:index] path]];
}

- (void)_loadImages
{
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.dir isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLNameKey];
    
    // 先获取缓存文件的相关属性
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants  | NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                                                                                   NSLog(@"error: %@", error);
                                                                                   return NO;
                                                                               }];
    
    NSMutableDictionary *imageFiles = [NSMutableDictionary dictionary];
    
    // 遍历目录下的所有文件
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        [imageFiles setObject:resourceValues forKey:fileURL];
    }
    
    _imageFileURLs = [imageFiles keysSortedByValueWithOptions:NSSortConcurrent
                                              usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                  return [obj1[NSURLNameKey] compare:obj2[NSURLNameKey] options:NSNumericSearch];
                                              }];
}

@end

