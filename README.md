# FFT_SoC
1.项目简介

设计一款256点定点FFT IP核（Q24.8格式），支持AXI4-Stream数据流接口。项目聚焦核心功能实现与基础验证流程，包含Verilog RTL设计、SystemVerilog验证环境搭建及基础覆盖率收集，适合初学者快速掌握IP开发全流程。

2.项目目标

实现256点FFT计算（基-2算法），支持AXI4-Stream输入/输出（含反压处理），定点Q24.8数据格式， 搭建SystemVerilog验证环境， 实现基础功能覆盖率（>85%），完成关键场景测试， 开发周期：2个月，代码规模：≤ 3000行Verilog。
    
3.项目内容

3.1算法建模

基于matlab软件进行算法建模，基-2 DIT FFT算法的核心是蝶形计算单元。

3.2项目架构

<img width="1506" height="875" alt="image" src="https://github.com/user-attachments/assets/893e85d1-517a-4f86-9ade-05b682a10e1d" />

3.3RTL设计

<img width="705" height="263" alt="image" src="https://github.com/user-attachments/assets/f6bc9619-f927-4399-a53f-5f5090fc02ea" />

3.4验证环境架构（搭建中）

