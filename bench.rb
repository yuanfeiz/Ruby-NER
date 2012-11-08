require 'rjb'
require 'builder'

MAP = {
    '[' => '-LRB-',
    ']' => '-RRB-',
    '{' => '-LCB-',
    '}' => '-RCB-',
}

def tokenize filepath
    text = File.read(filepath).force_encoding('utf-8')
    
    tokenized_text = text.gsub(/[(){}\[\]\.\,\s":]|(\'s)/) {|m| m = MAP[m] || m; "\n#{m}\n" }
        .gsub(/\n[\s]*\n/, "\n")
    tokenized_text.gsub(/#{MAP['{']}\n(.*?)?\/(n.?)\n#{MAP['}']}/m) {|m| $1.split("\n").map { |e| "#{e}\t#{$2}" }.join("\n") }
        .gsub(/^\S+$/)  {|m| "#{m}\tO"}
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

def build_xml(offsets)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml = builder.EntityExtraction do |entity_extraction|
        entity_extraction.Entities(count: offsets.size) do |entities|
            offsets.each do |offset|
                entities.Entity(type: offset[0]) do |entity|
                    entity.Text(offset[3])
                    entity.Doc(offset[1])
                    entity.Start(offset[2])
                end
            end
        end
    end
end

print "Test file name:"
# testfile_path = gets.chomp
testfile_path = "SampleTestData.txt"
puts testfile_path
res = process(testfile_path)

print "Output file name:"
# testfile_path = gets.chomp
resultfile_path = "my_result.xml"
puts resultfile_path
File.open(resultfile_path, 'w') do |file|
    file.write(build_xml(res))
end