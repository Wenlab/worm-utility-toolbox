# 填入参数

> %% 1.prepare basic parameters, DO NOT change afterwards.

1. 要分析的视频启始和结束帧数`istart`，`iend`
2. 后退和前进运动的帧数`reversal_frames`, `fwd_frames`。每行是一个完整的运动序列，例如 `reversal_frames=[50 100; 300 400]`, `fwd_frames=[1 49;101 299;400 1800]`
3. 如果在拍摄过程中移动了板子，填入移动板子时的帧数到`displacing_frames`。如在第700和900帧移动的板子，则`displacing_frames=[700;900]`。

# 开始处理视频

## 装载视频

> %% 2.load the video

运行这部分，选择视频
![image](https://github.com/Wenlab/worm-utility-toolbox/assets/15274805/3fa1c95c-d846-4ff0-b612-0fe9a173ffe8)


## 框定ROI

> %% 3.find the roi

等待动画结束后，鼠标在图像上会产生这样一个十字的标志，用于选择ROI区域，一般来说先点击图片左上角，锁定左上边界，再点右下角，锁定右下边界。待两个边界确定完毕后摁回车。

![image](https://github.com/Wenlab/worm-utility-toolbox/assets/15274805/3fffd0de-a0bd-4271-a47a-83b1cbcec672)
![image](https://github.com/Wenlab/worm-utility-toolbox/assets/15274805/49e5688e-bd77-491e-a487-c4f07a884635)




## 设置阈值 

> %% 4.Find a suitable threshold, so that the worm is as clear as possible and no larger impurities than the worm

运行该部分，会弹出以下界面，如果清晰就关闭

![image](https://github.com/Wenlab/worm-utility-toolbox/assets/15274805/bde00b22-8085-483e-b349-11a8f786d00d)

如果不清晰，则调整阈值（thred这个变量，150-250之间简单调下），重新运行该部分代码，使虫子较为清晰，且没有比虫子更大的杂质

## 提取质心

> %% 5.extract centroiddata

执行该部分内容会看到以下界面；黄色圈圈代表质心位置。方便检查。
![image](https://github.com/Wenlab/worm-utility-toolbox/assets/15274805/ef138a66-352a-4313-9150-4c0712d5b4ec)


# 画出轨迹图

> %% 6.preview the trajectory

> %% 7. draw crawling trajectory with colormap
