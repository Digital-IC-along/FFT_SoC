# FFT_SoC
1.项目简介
设计一款256点定点FFT IP核（Q24.8格式），支持AXI4-Stream数据流接口。项目聚焦核心功能实现与基础验证流程，包含Verilog RTL设计、SystemVerilog验证环境搭建及基础覆盖率收集，适合初学者快速掌握IP开发全流程。

2.项目目标
·   核心功能
    o   实现256点FFT计算（基-2算法）
    o   支持AXI4-Stream输入/输出（含反压处理）
    o   定点Q24.8数据格式
·   验证目标
    o   搭建SystemVerilog验证环境
    o   实现基础功能覆盖率（>85%）
    o   完成关键场景测试
·   资源目标
    o   开发周期：2个月
    o   代码规模：≤ 3000行Verilog
    
3.项目内容
3.1算法建模
  基于matlab软件进行算法建模
  基-2 DIT FFT算法的核心是蝶形计算单元：
  X(k) = A + W * B
  X(k+N/2) = A - W * B
  其中：
      o  A和B是第一和第二输入数据点
      o  W是旋转因子（复数）
      o  X(k)和X(k+N/2)是输出数据点

3.2项目架构
<img width="1506" height="875" alt="image" src="https://github.com/user-attachments/assets/893e85d1-517a-4f86-9ade-05b682a10e1d" />

3.3RTL设计
<img width="705" height="263" alt="image" src="https://github.com/user-attachments/assets/f6bc9619-f927-4399-a53f-5f5090fc02ea" />

3.4验证环境架构（搭建中）
TB_top
├── fft_driver.sv       // AXI4S驱动
├── fft_monitor.sv     // 输出采集
├── ref_model.py      // 参考模型
├── scoreboard.sv     // 幅值误差检查(±1 LSB)
└── test_cases.sv      // 手动编写测试场景、

