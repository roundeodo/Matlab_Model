function [message] = varicode_decode(bits)
    % 1. 定义 Varicode 查找表 (基于 ASCII 0~127)
varicode_table = [
	"1010101011"; "1011011011"; "1011101101"; "1101110111"; "1011101011"; "1101011111"; "1011101111"; "1011111101";
	"1011111111"; "11101111"  ; "11101"     ; "1101101111"; "1011011101"; "11111"     ; "1101110101"; "1110101011";
	"1011110111"; "1011110101"; "1110101101"; "1110101111"; "1101011011"; "1101101011"; "1101101101"; "1101010111";
	"1101111011"; "1101111101"; "1110110111"; "1101010101"; "1101011101"; "1110111011"; "1011111011"; "1101111111";
	"1"         ; "111111111" ; "101011111" ; "111110101" ; "111011011" ; "1011010101"; "1010111011"; "101111111" ;
    "11111011"  ; "11110111"  ; "101101111" ; "111011111" ; "1110101"   ; "110101"    ; "1010111"   ; "110101111" ;
    "10110111"  ; "10111101"  ; "11101101"  ; "11111111"  ; "101110111" ; "101011011" ; "101101011" ; "110101101" ;
    "110101011" ; "110110111" ; "11110101"  ; "110111101" ; "111101101" ; "1010101"   ; "111010111" ; "1010101111";
    "1010111101"; "1111101"   ; "11101011"  ; "10101101"  ; "10110101"  ; "1110111"   ; "11011011"  ; "11111101"  ;
    "101010101" ; "1111111"   ; "111111101" ; "101111101" ; "11010111"  ; "10111011"  ; "11011101"  ; "10101011"  ;
    "11010101"  ; "111011101" ; "10101111"  ; "1101111"   ; "1101101"   ; "101010111" ; "110110101" ; "101011101" ;
    "101110101" ; "101111011" ; "1010101101"; "111110111" ; "111101111" ; "111111011" ; "1010111111"; "101101101" ;
    "1011011111"; "1011"      ; "1011111"   ; "101111"    ; "101101"    ; "11"        ; "111101"    ; "1011011"   ;
    "101011"    ; "1101"      ; "111101011" ; "10111111"  ; "11011"     ; "111011"    ; "1111"      ; "111"       ;
	"111111"    ; "110111111" ; "10101"     ; "10111"     ; "101"       ; "110111"    ; "1111011"   ; "1101011"   ;
    "11011111"  ; "1011101"   ; "111010101" ; "1010110111"; "110111011" ; "1010110101"; "1011010111"; "1110110101";
];

    % 2. ASCII 索引 (0~127)
    ascii_table = char(0:127); % 生成 ASCII 对应的字符数组

    % 3. 将 bits 转换成字符串（'0' 和 '1'）
    bit_str = char(bits + '0')';

    % 4. 使用 "00" 作为分隔符，分割成 Varicode 码字
    varicode_words = strsplit(bit_str, "00");
    varicode_words = varicode_words(2:end-1);
    % 5. 遍历所有 Varicode 码字，在查找表中匹配
    message_chars = [];
    for i = 1:length(varicode_words)
        word = varicode_words{i};
        idx = find(varicode_table == word, 1); % 查找索引
        if ~isempty(idx)
            message_chars(end + 1) = ascii_table(idx);  % 查表得到 ASCII 字符
        else
            message_chars(end + 1) = ' ';  % 无效码字时，返回 '?'
        end
    end

    % 6. 拼接所有字符，返回解码后的消息
    message = string(message_chars);
end
