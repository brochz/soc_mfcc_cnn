简介: 基于 Cortex-M3 和 MFCC+CNN 的实时离线语音关键词识别系统

算法首先提取语音信号的梅尔频率倒谱系数(MFCC)特征, 然后通过CNN网络来进行分类.
硬件集成了cortex-M3核, 以及多个浮点加速运算单元, 比如MFCC特征提取加速器, 浮点速运算单元等.
硬件在FPGA上实现,软件使用C语言在ARM的uVision环境下开发,实际上版测试准确率高达90%.


文件路径说明:

doc/                                #该目录包含设计报告以及视频演示
    -- report.pdf                   #pdf版本设计报告
    -- 演示.mp4

hardware/                           #包含硬件设计代码和工程
    --build/vivado/              
        --build/vivado/vivado/      #整个系统vivado工程
    --rtl/                          #硬件rtl源码和Xilinx ip(xci文件)以及cortex_m3_ip
        --fpga_top.v   #FPGA顶层文件
        ...
    --tb/                           #testbench
        ...

software/...                        #包含c软件代码和uVision工程

training/                           #算法的测试和神经网络的训练, 以及一些其他脚本
    --main.ipynb                    #CNN训练                    
    --ex_mfcc.ipynb                 #mfcc特征提取
    --get*.ipynb                    #把参数和权重转换为C的数组
    ...