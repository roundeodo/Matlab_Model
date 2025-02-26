function clock_out = clock_recovery(raw_out, osr)
    %% 参数配置
    n_symbols = floor(length(raw_out)/osr);
    clock_out = zeros(1, n_symbols);
    phase_estimate = osr/2;       
    delta = round(osr);     % 调整窗口宽度
    phase_integral = 0;           
    
    %% 动态参数配置
    alpha_initial = 0.15;          % 初始快速收敛
    beta_initial = 0.005;         
    alpha_steady = 0.001;           % 稳态精细跟踪
    beta_steady = 0.0005;          
    
    %% 主处理循环
    for k = 1:n_symbols
        % 动态参数切换
        if k < 50
            alpha = alpha_initial;
            beta = beta_initial;
        else
            alpha = alpha_steady;
            beta = beta_steady;
        end
        
        % 符号数据提取
        start_idx = (k-1)*osr + 1;
        end_idx = k*osr;
        symbol_samples = raw_out(start_idx:end_idx);
        int_phase = round(phase_estimate);
        
        %=== 改进型符号统计 ===
        [early_diff, late_diff] = get_symbol_diff(symbol_samples, int_phase, delta, osr);
        
        %=== 误差生成 ===
        error = early_diff - late_diff;
        
        %=== 增强型环路滤波 ===
        phase_integral = phase_integral + beta * error;  
        phase_estimate = phase_estimate + alpha * error + phase_integral;
        
        %=== 相位平滑处理 ===
        phase_estimate = smooth_phase(phase_estimate, osr, k);
        
        % 记录采样点（四舍五入->线性插值）
        clock_out(k) = start_idx - 1 + interpolate_phase(phase_estimate, osr);
    end
    clock_out = clock_out / 16;
    clock_out = clock_out.';
end

%% 辅助函数：改进符号差异计算
function [early_diff, late_diff] = get_symbol_diff(samples, phase, delta, osr)
    % 早门窗口
    early_start = max(1, phase - delta);
    early_end = phase;
    if early_start > early_end
        early_diff = 0;
    else
        vals = samples(early_start:early_end);
        pos = sum(vals > 0.2);   % 增加门限抗噪声
        neg = sum(vals < -0.2);
        total = pos + neg + eps; % 避免除零
        early_diff = (pos - neg)/total;
    end
    
    % 迟门窗口
    late_start = phase + 1;
    late_end = min(osr, phase + delta);
    if late_start > late_end
        late_diff = 0;
    else
        vals = samples(late_start:late_end);
        pos = sum(vals > 0.2);
        neg = sum(vals < -0.2);
        total = pos + neg + eps;
        late_diff = (pos - neg)/total;
    end
end

%% 辅助函数：相位平滑
function phase = smooth_phase(phase, osr, k)
    persistent hist_phase;
    if isempty(hist_phase), hist_phase = zeros(1,5); end
    
    % 滑动平均滤波
    hist_phase = [phase, hist_phase(1:end-1)];
    phase = mean(hist_phase);
    
    % 相位循环处理
    phase = mod(phase-1, osr) + 1;
    
    % 前50个符号禁用平滑
    if k < 50
        phase = hist_phase(1);
    end
end

%% 辅助函数：相位插值
function pos = interpolate_phase(phase, osr)
    % 线性插值提高分辨率
    frac = phase - floor(phase);
    pos = floor(phase) + 0.5*sign(frac - 0.5);
    pos = max(1, min(osr, pos));
end