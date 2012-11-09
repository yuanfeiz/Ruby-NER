# encoding: utf-8
require 'rjb'
require 'builder'

MAP = {
    '[' => '-LRB-',
    ']' => '-RRB-',
    '{' => '-LCB-',
    '}' => '-RCB-',
}

class TextProcessor
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

class OutputBuilder
    def intialize(offsets)
        @offsets = offsets
        @xml = nil
    end

    def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

        @xml = builder.EntityExtraction do |entity_extraction|
            entity_extraction.Entitie0s(count: @offsets.size) do |entities|
                @offsets.each do |offset|
                    entities.Entity(type: offset[0]) do |entity|
                        entity.Text(offset[3])
                        entity.Doc(offset[1])
                        entity.Start(offset[2])
                    end
                end
            end
        end
    end

    def write_to_file(path)
        File.open(path, "w") { |io| io.write(self.to_xml) }
    end
end

def prepare
    print "input filename: "
    input_filename = gets.chomp
    input_path = File.expand_path(File.dirname(__FILE__)+'/' + input_filename)

    print "output filename: "
    output_filename = gets.chomp
    output_path = File.expand_path(File.dirname(__FILE__)+'/' + output_filename)

    File.open(output_path, 'w') do |file|
        file.write(tokenize(input_path))
    end
end

def process filepath
    Rjb::load('stanford-postagger.jar:stanford-ner.jar', ['-Xmx200m'])

    crfclassifier = Rjb::import('edu.stanford.nlp.ie.crf.CRFClassifier')
    Rjb::import('edu.stanford.nlp.ling.CoreAnnotations')
    classifier = crfclassifier.getClassifierNoExceptions("ner-model.ser.gz")

    # maxentTagger = Rjb::import('edu.stanford.nlp.tagger.maxent.MaxentTagger')
    # maxentTagger.init("left3words-wsj-0-18.tagger")

    # Sentence = Rjb::import('edu.stanford.nlp.ling.Sentence')


    # puts classifier.java_methods
    # classifier.testFile(filepath)

    res = []
    File.open(filepath) do |file|
        text = file.readlines
        text.each_with_index do |line, index|
            out = classifier.testStringAndGetCharacterOffsets( line )
            0.upto(out.size - 1) do |i|
                tri = out.get(i)
                offset_start = tri.second.toString.to_i
                offset_end = tri.third.toString.to_i
                res << [tri.first.toString, index + 1, offset_start, line[offset_start...offset_end]]
            end
        end
    end

    res
end



print "Test file name:"
# testfile_path = gets.chomp
testfile_path = "SampleTestData.txt"
puts testfile_path
res = process(testfile_path)

print "Output file name:"
# testfile_path = gets.chomp
resultfile_path = "my_result_#{Time.now.to_i}.xml"
puts resultfile_path
File.open(resultfile_path, 'w') do |file|
    file.write(build_xml(res))
end