# encoding: utf-8
require 'thor'

class Converter < Thor

  desc "", ""
  method_options :in => :string, :out => :string
  def gazette
    p 123
    linewise_do(options[:in], options[:out]) do |line|
      p '---'
      puts line
    end
  end

  no_tasks do
    def linewise_do(fin, fout, &block)
      buffer = []
      File.readlines(fin).each do |line|
        line = line.chomp.split(' ')
        line = block.call(line)
        buffer << line.join(' ')
      end
      if fout then
        File.open(fout, 'w') { |io| io.puts buffer.join("\n") }
      else
        puts buffer.join("\n")
      end
    end
  end


end