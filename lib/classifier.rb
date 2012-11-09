require 'rjb'

class Classifier
    def initialize(classifier_path = 'ner-model.ser.gz')
        Rjb::load('stanford-postagger.jar:stanford-ner.jar', ['-Xmx200m'])
        Rjb::import('edu.stanford.nlp.ling.CoreAnnotations')

        crfclassifier = Rjb::import('edu.stanford.nlp.ie.crf.CRFClassifier')
        @classifier = crfclassifier.getClassifierNoExceptions(classifier_path)
    end

    def process_paragraph(paragraph)
        java_result = classifier.testStringAndGetCharacterOffsets(paragraph)

        0.upto(java_result.size - 1).inject([]) do |arr, i|
            tri = java_result.get(i)
            offset_start = tri.second.toString.to_i
            offset_end = tri.third.toString.to_i

            arr << [tri.first.toString, offset_start, paragraph[offset_start...offset_end]]
        end
    end

    def process_document(document)
        res = []

        document.split('\n').each_with_index do |paragraph, index|
            res << process_paragraph(paragraph)                
        end

        add_doc_field(res)
    end

    def process_file(path)
        File.open(path, "r") { |io| process_document(io.read) }
    end

    def add_doc_field(res)
        res.enum_with_index.map do |e, i|
            e.map { |o| o << i }
        end
    end
end