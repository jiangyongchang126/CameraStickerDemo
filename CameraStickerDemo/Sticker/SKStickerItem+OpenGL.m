//
//  SKStickerItem+OpenGL.m
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/5.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKStickerItem+OpenGL.h"

#import <objc/runtime.h>
#import <OpenGLES/ES2/gl.h>

static void *kTexturesWrapperKey = &kTexturesWrapperKey;

@interface SKTexturesWrapper : NSObject

- (instancetype)initWithSize:(NSUInteger)size;

- (GLuint)textureAtIndex:(NSUInteger)index;
- (void)setTexture:(GLuint)texture atIndex:(NSUInteger)index;

- (void)removeAllTextures;

@end


@implementation SKTexturesWrapper
{
    GLuint *_textureArr;
    NSUInteger _size;
}

- (void)dealloc
{
    [self removeAllTextures];
}

- (instancetype)initWithSize:(NSUInteger)size
{
    self = [super init];
    if (self) {
        _size = size;
    }
    
    return self;
}

- (GLuint)textureAtIndex:(NSUInteger)index
{
    if (_textureArr == NULL) {
        _textureArr = (GLuint *)malloc(_size * sizeof(GLuint));
        if (_textureArr == NULL) {
            // 分配内存失败
            return 0;
        }
        
        for (int i = 0; i < _size; i++) {
            _textureArr[i] = 0;
        }
    }
    
    return _textureArr[index];
}

- (void)setTexture:(GLuint)texture atIndex:(NSUInteger)index
{
    _textureArr[index] = texture;
}

- (void)removeAllTextures
{
    if (_textureArr) {
        glDeleteTextures((GLsizei)_size, _textureArr);
        free(_textureArr);
        _textureArr = NULL;
    }
}

@end


@implementation SKStickerItem (OpenGL)

- (SKTexturesWrapper *)textures
{
    SKTexturesWrapper *wrapper = objc_getAssociatedObject(self, kTexturesWrapperKey);
    if (!wrapper) {
        wrapper = [[SKTexturesWrapper alloc] initWithSize:self.count];
        objc_setAssociatedObject(self, kTexturesWrapperKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return wrapper;
}

- (GLuint)_textureWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        // Failed to load image
        return 0;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    free(imageData);
    
    return texture;
}

- (GLuint)_textureAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return 0;
    }
    
    GLuint texture = [[self textures] textureAtIndex:index];
    if (texture == 0) {
        texture = [self _textureWithImage:[self imageAtIndex:index]];
        [[self textures] setTexture:texture atIndex:index];
    }
    
    return texture;
}

- (GLuint)nextTextureForInterval:(NSTimeInterval)interval
{
    self.currentFrameIndex = [self nextFrameIndexForInterval:interval];
    
    return [self _textureAtIndex:self.currentFrameIndex];
}

- (void)deleteTextures
{
    [[self textures] removeAllTextures];
}

@end
