function message = varicode_decode_fsm_tree(bits, root)
%VARICODE_DECODE_FSM_TREE 逐位解析 bits，通过前缀树(FSM)解码
%  bits: [0;1;1;0;...] 列向量或行向量的 0/1
%  root: 由 buildVaricodeTree(table) 生成的树根节点
%
%返回值：
%  message: 解出的ASCII字符串

    % 保证 bits 是行向量方便处理
    bits = bits(:)';  
    n = length(bits);

    % 当前所在树节点，从 root 开始
    node = root;

    msgChars = [];  % 存放解码出的字符
    
    i = 1;
    while i <= n
        if bits(i) == 1
            % 处理 '1': 往右子节点走
            if isempty(node.right)
                % 若为空，表示码字非法或比特流出错
                % 可作容错处理：直接回到root或丢弃
                msgChars(end+1) = '?';
                node = root;
            else
                node = node.right;
            end

            % 如果该节点存了 ascii，表示到了叶子
            if ~isempty(node.ascii)
                % 输出字符
                msgChars(end+1) = char(node.ascii);
                % 重置回根节点
                node = root;
            end

            i = i + 1;  % 处理下一个比特

        else
            % bits(i) == 0
            if i < n && bits(i+1) == 0
                % 连续两个 0 => 表示码字结束
                % 说明前面 path(即 node)对应一个完整的码字
                if ~isempty(node.ascii)
                    msgChars(end+1) = char(node.ascii);
                else
                    % 如果没 ascii，说明码字不合法
                    msgChars(end+1) = '?';
                end
                % 回到根节点
                node = root;
                
                % 跳过这两个连续 0
                i = i + 2;
            else
                % 单个 '0' => 往左子节点走
                if isempty(node.left)
                    % 若为空，表示码字非法
                    msgChars(end+1) = '?';
                    node = root;
                else
                    node = node.left;
                end

                if ~isempty(node.ascii)
                    % 若此节点是叶子，则输出字符
                    msgChars(end+1) = char(node.ascii);
                    node = root;
                end

                i = i + 1;
            end
        end
    end

    % 可能还有尾部未结束就到比特串结尾，这里视情况处理
    % 若 node.ascii非空，可以加一次输出，具体看设计需求

    message = string(msgChars);
end