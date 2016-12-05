//
//  SKStickerManager.m
//  PLMediaStreamingKitDemo
//
//  Created by Sinkup on 2016/10/13.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKSticker.h"

@implementation SKStickersManager
{
    dispatch_queue_t _ioQueue;
    NSFileManager *_fileManager;
    
    NSBundle *_stickerBundle;
}

+ (instancetype)sharedManager
{
    static id _stickersManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _stickersManager = [SKStickersManager new];
    });
    
    return _stickersManager;
}

+ (void)loadStickersWithCompletion:(void (^)(NSArray<SKSticker *> *))completion
{
    [[self sharedManager] _loadStickersWithCompletion:completion];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("design.asura.stickers", DISPATCH_QUEUE_SERIAL);
        _fileManager = [[NSFileManager alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SKStickerResources" ofType:@"bundle"];
        _stickerBundle = [NSBundle bundleWithPath:path];
    }
    
    return self;
}


#pragma mark - Private
- (void)_loadStickersWithCompletion:(void(^)(NSArray<SKSticker *> *))completion
{
    dispatch_async(_ioQueue, ^{
        NSArray *stickers = [self _loadStickers];
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(stickers);
        });
    });
}

- (NSArray *)_loadStickers
{
    NSURL *diskCacheURL = [NSURL fileURLWithPath:[_stickerBundle.bundlePath stringByAppendingPathComponent:@"stickers"]
                                     isDirectory:YES];
    NSArray *resourceKeys = @[ NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey ];
    
    // 先获取缓存文件的相关属性
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                               includingPropertiesForKeys:resourceKeys
                                                                  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                             errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                                                                 NSLog(@"error: %@", error);
                                                                 return NO;
                                                             }];
    
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    
    // 遍历目录下的所有文件
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        if (![resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    // 根据文件名排序
    NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                    usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                        return [obj1[NSURLNameKey] localizedCompare:obj2[NSURLNameKey]];
                                                    }];
    
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:sortedFiles.count];
    
    for (NSURL *fileURL in sortedFiles) {
        SKSticker *sticker = [[SKSticker alloc] initWithDirectoryURL:fileURL];
        if (sticker) {
            [stickers addObject:sticker];
        }
    }
    
    return [NSArray arrayWithArray:stickers];
}

@end


@implementation SKSticker

- (instancetype)initWithDirectoryURL:(NSURL *)url
{
    NSString *dir = url.path;
    NSString *configFile = [dir stringByAppendingPathComponent:@"meta.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFile isDirectory:NULL]) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:configFile];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error || !dict) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _dir = dir;
        
        _name = [dict objectForKey:@"name"];
        _preview = [dict objectForKey:@"preview"];
        _audio = [dict objectForKey:@"audio"];
        
        NSArray *itemsDict = [dict objectForKey:@"items"];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsDict.count];
        for (NSDictionary *itemDict in itemsDict) {
            SKStickerItem *item = [[SKStickerItem alloc] initWithJSONDictionary:itemDict];
            item.dir = [_dir stringByAppendingPathComponent:item.dir];
            
            [items addObject:item];
        }
        
        _items = items;
    }
    
    return self;
}

@end
