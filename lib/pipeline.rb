#!/usr/bin/env ruby
# encoding: utf-8
require 'cocaine'
require 'tempfile'
require 'benchmark'
require 'thor'
require File.expand_path(File.dirname(__FILE__) + '/lib/string_ext')
require File.expand_path(File.dirname(__FILE__) + '/lib/xml_builder')

class NerPipeline < Thor
  include Thor::Actions

  SEGMENTER_DIR = 'stanford-segmenter-2012-11-11'
  POSTAGGER_DIR = 'stanford-postagger-full-2012-11-11'

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
    params = {
      model: 'ctb', # => alter. pku
      filename: File.expand_path(input_file),
      encoding: 'UTF-8',
      size: '0'
    }
    res = nil

    inside(SEGMENTER_DIR) do
      res = run("segment.sh #{params[:model]} #{params[:filename]} #{params[:encoding]} #{params[:size]}", with: "sh", capture: true, swallow_stderr: true)
    end
    res.chomp_bracket!(false)
    res.chomp!

    res
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
    path = store_result(res)
    res = extract_prefix_and_surfix(path, nil, 2)

    res
  end

  desc 'pipeline --in input --out output --slice-size size', ''
  method_options :in => :string, :out => :string, :'slice-size' => 50, :s => :string
  def pipeline(fin = options[:in], fout = options[:out], slice_size = options[:'slice-size'], split_line = options[:s])
    slice_size ||= 50
    i = 0
    res = nil
    File.readlines(fin).each_slice(slice_size) do |lines|
      p (i += 1)
      str = lines.map(&:chomp).join(split_line)
      path = store_result(str)
      res = pipeline_line(path)

      File.open(fout, "a") { |io| io.puts(res) } if fout
    end

    res
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

  desc 'extract_prefix_and_surfix --in [INPUT_FILE]', ''
  method_options :in => :string, :out => :string, :at => 2
  def extract_prefix_and_surfix(fin = options[:in], fout = options[:out], at = options[:at])
    buffer = []
    File.readlines(fin).each do |line|
      line = line.chomp.split(' ')

      word = line.first
      line.insert(at, word[-1])
      line.insert(at, word[0])

      line.join(' ')
      buffer << line.join(' ')
    end

    res = buffer.join("\n")
    create_file fout, res if fout

    res
  end

  desc 'label if in gazette', ''
  method_options :in => :string, :out => :string, :at => -2, :gazette => :string
  def label_gazette
    buffer = []
    gazette = File.read(options[:gazette]).split("\r\n")
    File.readlines(options[:in]).each do |line|
      line = line.chomp.split(' ')
      label = ''

      if (line[0].length > 1) and (line[0].length < 4) and (gazette.include? line[-3]) then
        label = 'InSurnameList'
      else
        label = 'NotInSurnameList'
      end

      line.insert(options[:at], label)

      buffer << line.join(' ')
    end

    if options[:out] then
      create_file fout, buffer.join("\n") if fout
    else
      puts buffer.join("\n")
    end
  end

  desc "", ""
  method_options :in => :string, :out => :string
  def gazette(fin = options[:in], fout = options[:out])
    str = linewise_do(fin) do |line_components|
      ["{#{line_components.first}/nr}"]
    end

    buffer = str.gsub!("\n", "")
    res = pipeline_line(store_result(buffer)).gsub!("PER", "InGazatteer-PER")
    save_to(res, fout)

    res
  end

  desc "test --in INPUT_FILE --out OUTPUT_FILE --model MODEL_FILE", "test file and output the result in xml"
  method_options :in => :string, :out => :string, :model => :string
  def test(fin = options[:in], fout = options[:out], model = options[:model])
    path = store_result(pipeline(fin, nil, 50, 'EOP'))
    command = Cocaine::CommandLine.new('crf_test', '-m :model :filename')
    params = {
      model: model,
      filename: path
    }
    res = command.run(params)
    res.extend XmlBuilder
    res = res.to_xml

    create_file fout, res if fout

    res
  end



  no_tasks do

  def save_to(res, fout)
    create_file fout, res if fout
  end

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

  def linewise_do(fin, &block)
    buffer = []
    File.readlines(fin).each do |line|
      line = line.chomp.split(' ')
      line = block.call(line)
      buffer << line.join(' ')
    end


    buffer.join("\n")
  end

  end
end