# encoding: utf-8
require 'cocaine'
require 'tempfile'
require 'benchmark'
require 'log4r'



module NLP
  def chomp_bracket!
    self.gsub!('}{', '} {')
    capture_bracket_regexp = /\{(.*?)\}/
    self.gsub!(capture_bracket_regexp) do
      $1.tr(' ', '')
    end
  end

  def linerize!
    self.gsub!(' ', "\n").gsub(/^#.*$/, '')
  end

  def to_crf_input!
    self.gsub!('#', ' ')
  end
end

class String
  include NLP
end

SEGMENTER_DIR = '/Users/stranbird/Documents/NLP/stanford-segmenter-2012-11-11'
POSTAGGER_DIR = '/Users/stranbird/Documents/NLP/stanford-postagger-full-2012-11-11'

def normalize(input_file, options = {})
  doc = File.read(input_file)
  capture_tags_regexp = /{(.*?)\/(.*?)}/

  doc.gsub(capture_tags_regexp) do
    if options[:keep_bracket] then
      '{' + $1 + '}'
    else
      $1
    end
  end
end



def segment(input_file)
  segmenter = File.join(SEGMENTER_DIR, 'segment.sh')
  segment_command = Cocaine::CommandLine.new(segmenter, ':model :filename :encoding :size', swallow_stderr: true)
  params = {
    model: 'ctb', # => alter. pku
    filename: input_file,
    encoding: 'UTF-8',
    size: '0'
  }
  res = nil
  segment_time = Benchmark.realtime do
    res = segment_command.run(params)
  end
  res.chomp_bracket!
  res.chomp!

  [res, segment_time]
end

def postag(input_file)
  postagger = File.join(POSTAGGER_DIR, 'stanford-postagger.sh')
  postag_command = Cocaine::CommandLine.new(postagger, ':model :filename', swallow_stderr: true)
  params = {
    model: File.join(POSTAGGER_DIR, 'models', 'chinese-distsim.tagger'),
    filename: input_file
  }

  res = nil
  postag_time = Benchmark.realtime do
    res = postag_command.run(params)
  end
  res.chomp!

  [res, postag_time]
end

def store_result(res)
  tmpfile = Tempfile.new('result')
  tmpfile.write(res)
  tmpfile.close

  tmpfile.path
end

# res = normalize(ARGV[0], keep_bracket: true)
# path = store_result(res)
# res, segment_time = segment(path)
# path = store_result(res)
# res, postag_time = postag(path)
# res.linerize!.to_crf_input!

# puts res
# puts "segment: #{segment_time}s"
# puts "postag: #{postag_time}s"