function BER = compute_BER(encode_in, encode_out)
    % 确保输入信号是列向量
    if size(encode_in, 2) ~= 1 || size(encode_out, 2) ~= 1
        error('输入信号必须是列向量');
    end

    % 确保两个信号长度相同
    if length(encode_in) ~= length(encode_out)
        error('输入信号和输出信号的长度不匹配');
    end

    % 计算误码数
    num_errors = sum(encode_in ~= encode_out); % 统计不相等的比特数
    total_bits = length(encode_in);            % 总比特数
    BER = num_errors / total_bits;             % 计算误码率

    % 显示误码率
    fprintf('误码率 (BER) = %.6f (%d / %d)\n', BER, num_errors, total_bits);
end
