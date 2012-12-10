#!/usr/bin/env ruby
# encoding: utf-8
require 'cocaine'
require 'tempfile'
require 'benchmark'
require 'thor'
require File.expand_path(File.dirname(__FILE__) + '/string_ext')

class NLPPipeline < Thor

  SEGMENTER_DIR = '/Users/stranbird/Documents/NLP/stanford-segmenter-2012-11-11'
  POSTAGGER_DIR = '/Users/stranbird/Documents/NLP/stanford-postagger-full-2012-11-11'

  desc 'normalize input_file', 'Normalize file'
  method_options :verbose => :boolean
  def normalize(input_file, params = {})
    doc = File.read(input_file)
    capture_tags_regexp = /{(.*?)\/(.*?)}/

    res = doc.gsub(capture_tags_regexp) do
      if params[:keep_bracket] then
        '{' + $1 + '}'
      else
        $1
      end
    end
    puts res if options[:verbose]

    res
  end

  desc 'segment input_file', ''
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

  desc 'postag input_file', ''
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

  desc 'pipeline input_file', ''
  def pipeline(input_file)
    res = normalize(input_file, keep_bracket: true)
    path = store_result(res)
    res, segment_time = segment(path)
    path = store_result(res)
    res, postag_time = postag(path)
    res.linerize!.to_crf_input!

    puts res
    puts "segment: #{segment_time}s"
    puts "postag: #{postag_time}s"
  end

private
  def store_result(res)
    tmpfile = Tempfile.new('result')
    tmpfile.write(res)
    tmpfile.close

    tmpfile.path
  end
end

NLPPipeline.start