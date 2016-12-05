# CameraStickerDemo
基于GPUImage的贴纸滤镜。可以借助人脸跟踪程序获取脸部的关键点数据，然后将贴纸资源绘制到实时视频流的相应位置上。

贴纸资源以文件形式保存，并使用`meta.json`配置其相关参数，通过代码读取并加载，包括`SKSticker`和`SKStickerItem`两个主要的类。

`SKStickerFilter`用于绘制贴纸，继承自`GPUImageFilter`。


### 人脸数据
此Demo中不包含人脸跟踪程序，人脸数据为保存在文件中的假数据，仅作演示用。


### 效果图
<p><a href="https://github.com/Sinkup/CameraStickerDemo/blob/master/CameraStickerDemo/Sticker/SKStickerResources.bundle/stickers/angel/preview.jpg" target="_blank"><img src="https://github.com/Sinkup/CameraStickerDemo/blob/master/CameraStickerDemo/Sticker/SKStickerResources.bundle/stickers/angel/preview.jpg?raw=true" alt="alt text" height="548" width="309"></a></p>



