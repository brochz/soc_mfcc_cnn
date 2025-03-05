**English:**

### Introduction: Real-Time Offline Speech Keyword Recognition System (FPGA System, CPU=ARM Cortex-M3)

The algorithm first extracts the Mel Frequency Cepstral Coefficients (MFCC) features of the speech signal and then classifies it using a Convolutional Neural Network (CNN).

The hardware integrates a Cortex-M3 core and multiple floating-point acceleration units, such as an MFCC feature extraction accelerator and a floating-point arithmetic unit. The hardware is implemented on an FPGA, while the software is developed in C within the ARM uVision environment. Practical testing on the actual board achieved an accuracy rate of up to 90%.

### File Path Description:

- **doc/**: Contains design reports and video demonstrations.
    - `report.pdf`: PDF version of the design report.
    - `演示.mp4`: Demonstration video.
- **hardware/**: Includes hardware design code and projects.
    - `build/vivado/`: Entire Vivado project for the system.
    - `rtl/`: RTL source code, Xilinx IP (XCI files), and Cortex-M3 IP.
        - `fpga_top.v`: Top-level file for the FPGA.
        - ...
    - `tb/`: Testbench files.
        - ...
- **software/**: Contains C software code and uVision projects.
- **training/**: Includes algorithm testing, neural network training, and additional scripts.
    - `main.ipynb`: CNN training.
    - `ex_mfcc.ipynb`: MFCC feature extraction.
    - `get*.ipynb`: Converts parameters and weights into C arrays.

<div style="text-align: center">⁂</div>

**中文:**

### 简介: 基于 Cortex-M3 和 MFCC+CNN 的实时离线语音关键词识别系统

算法首先提取语音信号的梅尔频率倒谱系数(MFCC)特征，然后通过CNN网络进行分类。

硬件集成了Cortex-M3核，以及多个浮点加速运算单元，比如MFCC特征提取加速器、浮点运算单元等。硬件在FPGA上实现，软件使用C语言在ARM的uVision环境下开发，实际板测试准确率高达90%。

### 文件路径说明:

- **doc/**: 该目录包含设计报告以及视频演示
    - `report.pdf`: PDF版本设计报告
    - `演示.mp4`: 演示视频
- **hardware/**: 包含硬件设计代码和工程
    - `build/vivado/`: 整个系统的Vivado工程
    - `rtl/`: 硬件RTL源码、Xilinx IP (XCI文件) 以及Cortex-M3 IP
        - `fpga_top.v`: FPGA顶层文件
        - ...
    - `tb/`: Testbench文件
        - ...
- **software/**: 包含C软件代码和uVision工程
- **training/**: 算法测试、神经网络训练及其他脚本
    - `main.ipynb`: CNN训练
    - `ex_mfcc.ipynb`: MFCC特征提取
    - `get*.ipynb`: 将参数和权重转换为C数组
        - ...

<div style="text-align: center">⁂</div>
