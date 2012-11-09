class TextProcessor
    # StanfordCoreNLP specific symbol mapping
    MAP = {
        '[' => '-LRB-',
        ']' => '-RRB-',
        '{' => '-LCB-',
        '}' => '-RCB-',
    }

    def initialize(text)
        @text = text || ""
    end

    def tokenize
        tokenized_text = @text.gsub(/[(){}\[\]\.\,\s":]|(\'s)/) {|m| m = MAP[m] || m; "\n#{m}\n" }
            .gsub(/\n[\s]*\n/, "\n")
        tokenized_text.gsub(/#{MAP['{']}\n(.*?)?\/(n.?)\n#{MAP['}']}/m) {|m| $1.split("\n").map { |e| "#{e}\t#{$2}" }.join("\n") }
            .gsub(/^\S+$/)  {|m| "#{m}\tO"}
    end

    # 从文件读取文本
    def read_from_file(path)
        @text = File.read(path).force_encoding('utf-8')
    end

    # 将结果保存到文件
    def save_to_file(path)
        File.open(path, "w") { |io| io.write(self.tokenize) }
    end
end