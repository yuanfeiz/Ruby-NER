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
    segment_command = Cocaine::CommandLine.new(segmenter, ':model :filename :encoding :size', swallow_stderr: false)
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
    res.chomp_bracket!(false)
    res.chomp!

    [res, segment_time]
  end

  desc 'postag input_file', ''
  def postag(input_file)
    postagger = File.join(POSTAGGER_DIR, 'stanford-postagger.sh')
    postag_command = Cocaine::CommandLine.new(postagger, ':model :filename', swallow_stderr: false)
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

  desc 'pipeline_line one_line_input_file', ''
  def pipeline_line(input_file)
    origin_text = strip(input_file)

    res = normalize(store_result(origin_text), keep_bracket: true)
    path = store_result(res)
    res, segment_time = segment(path)
    path = store_result(res)
    res, postag_time = postag(path)
    res.linerize!.to_crf_input!
    index_tbl = index_tag(store_result(origin_text))
    path = store_result(res)
    res = label(path, index_tbl)

    res
  end

  desc 'pipeline --in input --out output --slice-size size', ''
  method_options :in => :string, :out => :string, :'slice-size' => 50
  def pipeline
    i = 0
    File.readlines(options[:in]).each_slice(options[:'slice-size']) do |lines|
      p (i += 1)
      str = lines.map(&:chomp).join('')
      path = store_result(str)
      res = pipeline_line(path)

      File.open(options[:out], "a") { |io| io.puts(res) }
    end
  end

  desc 'label input_file', 'label with IOB'
  def label(input_file, index)
    res = []
    current_index = 0
    current_token = index.shift
    File.readlines(input_file).each do |line|
      line.chomp!
      word = line.split(' ').first
      line_res = ''
      l = ''
      if (not current_token.nil?) and (current_index < (current_token[1] + current_token[2])) then
        if (current_index >= current_token[1]) then
          if current_index == current_token[1] then
            l = 'B-' + current_token.last
          else
            l = 'I-' + current_token.last
          end
        else
          l = 'O'
        end
        current_token = index.shift if current_index + word.length == current_token[1] + current_token[2]
      else
        l = 'O'
      end

      res << (line + ' ' + l)
      current_index += word.length
    end

    res.join("\n")
  end

  desc 'index_tag input_file', 'index tag of origin input file'
  def index_tag(input_file)
    res = []
    str = File.read(input_file)
    offset = 0
    str.scan(/{(.*?)\/(n[a-z])}/) do |ne, type|
      res << [ne, $~.offset(0)[0] - offset, ne.length, type.to_cardinal]
      offset += 5
    end

    res
  end

  desc 'check_column_size --in input_file', ''
  method_options :in => :string
  def check_column_size
    File.readlines(options[:in]).each_with_index do |line, index|
      puts "#{index}:#{line}" unless line.split(' ').length == 3
    end
  end

  desc 'sub_label --in [INPUT_FILE] --from [TOKEN] --to [TOKEN]', ''
  method_options :in => :string, :out => :string, :from => 'BRI', :to => 'O'
  def sub_label
    num = 0
    buffer = []
    File.readlines(options[:in]).each do |line|
      line = line.chomp.split(' ')
      begin
        line[-1] = options[:to]
        num += 1
      end if line.last.end_with? options[:from]
      line.join(' ')
      buffer << line.join(' ')
    end

    if options[:out] then
      File.open(options[:out], 'w') { |io| io.puts buffer.join("\n") }
    else
      puts buffer.join("\n")
    end

    puts "Substitued #{num} label(s)."
  end

  no_tasks do

  def store_result(res)
    tmpfile = Tempfile.new('result')
    tmpfile.write(res)
    tmpfile.close

    tmpfile.path
  end

  def strip(input_file)
    str = File.read(input_file)
    str.gsub(/\{.*?\}/) { |match| match.gsub('?', '') }
  end

  end
end

NLPPipeline.start