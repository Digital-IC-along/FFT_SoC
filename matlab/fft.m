%% 256点基-2 FFT算法建模
clear; clc; close all;

%% 参数设置
N = 256;            % FFT点数
Q = 8;              % Q格式的小数部分位宽
Fs = 1000;          % 采样频率 (Hz)
f1 = 50;            % 信号频率1 (Hz)
f2 = 120;           % 信号频率2 (Hz)
A1 = 0.7;           % 信号1幅度
A2 = 0.3;           % 信号2幅度

%% 1. 生成测试信号
t = (0:N-1)/Fs;     % 时间向量
x = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t); % 合成信号


%% 2. 运行三种FFT实现
% MATLAB内置FFT作为参考
X_ref = fft(x);     

% 浮点模型
X_float = fft_float(x);

% 定点模型
X_fixed = fft_fixed(x, Q);
X_fixed = double(X_fixed); % 转换为双精度用于比较

disp(X_fixed)

%% 3. 结果比较与分析
% 计算误差
error_float = abs(X_ref - X_float);
error_fixed = abs(X_ref - X_fixed);

% 计算信噪比 (SNR)
snr_float = 20*log10(norm(X_ref)/norm(X_ref - X_float));
snr_fixed = 20*log10(norm(X_ref)/norm(X_ref - X_fixed));

fprintf('浮点模型SNR: %.2f dB\n', snr_float);
fprintf('定点模型SNR: %.2f dB\n', snr_fixed);

%% 4. 可视化结果
% 时域信号
figure('Position', [100, 100, 1200, 800]);
subplot(3, 2, 1);
plot(t, x);
title('时域信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;

% 参考FFT频谱
subplot(3, 2, 2);
f = (0:N-1)*(Fs/N);
plot(f, abs(X_ref));
title('MATLAB内置FFT');
xlabel('频率 (Hz)');
ylabel('幅度');
xlim([0 Fs/2]);
grid on;

% 浮点模型FFT频谱
subplot(3, 2, 3);
plot(f, abs(X_float));
title('浮点模型FFT');
xlabel('频率 (Hz)');
ylabel('幅度');
xlim([0 Fs/2]);
grid on;

% 定点模型FFT频谱
subplot(3, 2, 4);
plot(f, abs(X_fixed));
title('定点模型FFT (Q24.8)');
xlabel('频率 (Hz)');
ylabel('幅度');
xlim([0 Fs/2]);
grid on;

% 浮点模型误差
subplot(3, 2, 5);
plot(f, error_float);
title('浮点模型误差');
xlabel('频率 (Hz)');
ylabel('误差幅度');
xlim([0 Fs/2]);
grid on;

% 定点模型误差
subplot(3, 2, 6);
plot(f, error_fixed);
title('定点模型误差');
xlabel('频率 (Hz)');
ylabel('误差幅度');
xlim([0 Fs/2]);
grid on;
%% 基-2 DIT FFT浮点模型实现
function X = fft_float(x)
    N = length(x);
    stages = log2(N);%蝶形计算级数
    
    % 位反转重排输入
    bit_rev_idx = bitrevorder(1:N);
    X = x(bit_rev_idx);
    
    % 蝶形计算
    for stage = 1:stages
        step = 2^stage;
        half_step = step/2;
        
        for group = 0:step:N-1
            for k = 0:half_step-1
                idx1 = group + k + 1;
                idx2 = idx1 + half_step;
                
                % 获取旋转因子
                angle = -2*pi*k/step;
                W = cos(angle) + 1i*sin(angle);
                
                % 蝶形运算
                temp = X(idx1);
                X(idx1) = temp + W * X(idx2);
                X(idx2) = temp - W * X(idx2);
            end
        end
    end
end
%% 基-2 DIT FFT定点模型实现
function X_fixed = fft_fixed(x, Q)
    % 将浮点信号转换为Q24.8格式
    x_fixed = fi(x, 1, 32, Q); % 有符号定点数，32位总宽，Q位小数
    
    N = length(x_fixed);
    stages = log2(N);
    
    % 位反转重排输入
    bit_rev_idx = bitrevorder(1:N);
    X_fixed = x_fixed(bit_rev_idx);
    
    % 蝶形计算
    for stage = 1:stages
        step = 2^stage;
        half_step = step/2;
        
        for group = 0:step:N-1
            for k = 0:half_step-1
                idx1 = group + k + 1;
                idx2 = idx1 + half_step;
                
                % 获取旋转因子 (Q24.8格式)
                angle = -2*pi*k/step;
                W_real = fi(cos(angle), 1, 32, Q);
                W_imag = fi(sin(angle), 1, 32, Q);
                W = complex(W_real, W_imag);
                
                % 蝶形运算
                A = X_fixed(idx1);
                B = X_fixed(idx2);
                
                % 复数乘法 (B * W)
                prod_real = B.real * W.real - B.imag * W.imag;
                prod_imag = B.real * W.imag + B.imag * W.real;
                
                % 转换为Q24.8格式 (保留32位中间结果，然后移位)
                prod_real = fi(prod_real, 1, 32, 2*Q);
                prod_imag = fi(prod_imag, 1, 32, 2*Q);
                
                % 蝶形输出
                X_fixed(idx1) = A + complex(prod_real, prod_imag);
                X_fixed(idx2) = A - complex(prod_real, prod_imag);
            end
        end
    end
end