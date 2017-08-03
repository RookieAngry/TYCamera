# TYCamera
TYCamera对AVFoundation与视频、拍照相关的功能进行了封装，暴露了与实际开发中常用的API接口，方便开发者调用，并实现视频拼接功能以及移除对应下标的视频片段。开发者只要致力于拍照/视频录制相关的界面的搭建即可，提升开发效率。     

支持cocoaPods: pod 'TYCamera', '~> 1.0.1';

### TYCamera简介:
TYCamera共有四个类组成:   

    a.TYCameraVC类:该类为TYCamera暴露的最外层的类，开发者继承该类进行相关界面布局;
    b.TYRecordEngine类：该类是对AVFoundation视频、拍照相关功能的封装，并暴露相关的API，例如：闪光灯相关，切换摄像头相关等功能；
    c.TYRecordEncoder类：该类是相机采集到相关数据后，使用AVAssetWriter将数据写入本地文件；
    d.TYRecordHelper类：该类提供了一些工厂方法，例如：将视频转换为MP4格式，获取视频封面图（第一帧），将视频片段进行拼接整合等方法。
### TYCamera的简单使用：    
    1.下载该项目，将项目中的Camera文件拖入项目中；
    2.创建新的控制器继承TYCameraVC;
    3.在需要跳入拍照/录制视频的位置使用工厂方法初始化控制器，并设置相关的参数
    4.调用TYCameraVC暴露的相关接口开发界面逻辑
### TYCamera Demo说明：    
在此工程中，共包括两个Demo，一是拍摄照片，二是录制视频。此Demo是模仿新浪微博的摄像功能实现，但并未合并拍照以及录制视频功能，如需将拍照与录制视频功能写在一个控制器中，只需在初始化TYCameraVC时将recordType属性设置为TYCameraVCTypeBoth（默认为该属性）即可。    
     
     代码示例:    
     a.初始化TYCameraVC:
     // 初始化拍照功能的控制器
     TYTakePhotoVC *takePhotovc = [TYTakePhotoVC recordEngineSessionPreset:AVCaptureSessionPresetHigh 
                                                             devicePosition:AVCaptureDevicePositionFront 
                                                                 recordType:TYCameraVCTypePhoto 
                                                               previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
     [self.navigationController pushViewController:takePhotovc animated:YES];
    
    // 初始化录制视频功能控制器
    TYTakeVideoVC *takeVideovc = [TYTakeVideoVC recordEngineSessionPreset:AVCaptureSessionPresetHigh 
                                                           devicePosition:AVCaptureDevicePositionFront 
                                                               recordType:TYCameraVCTypeVideo 
                                                             previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
    takeVideovc.minDuration = 3.f; // 设置录制视频的最短时长
    takeVideovc.maxDuration = 15.f; // 设置录制视频的最长时长
    [self.navigationController pushViewController:takeVideovc animated:YES];
    
    // 初始化具有拍照功能和视频录制功能的控制器
    TYCustomCameraVC *customCameravc = [TYCustomCameraVC recordEngineSessionPreset:AVCaptureSessionPresetHigh 
                                                                    devicePosition:AVCaptureDevicePositionFront 
                                                                        recordType:TYCameraVCTypeBoth 
                                                                      previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
    [self.navigationController pushViewController:customCameravc animated:YES];
    
    b.初始化完成后，界面逻辑相关的API已暴露在TYCameraVC.h中，请参照相关注释使用相应功能       
### 后续目标
- 添加自定义滤镜，实现美颜功能
- 对AVPlayer进行相应封装，实现基本功能
- 修复该项目中出现的问题。



