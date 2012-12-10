# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
input_file = '/Users/stranbird/Documents/NLP/stanford-segmenter-2012-11-11/test.simp.utf8'
input_file_1 = '/Users/stranbird/Documents/NLP/TrainingData.txt'
# guard 'shell' do
#   watch(/(.*).rb/) {|m| `ruby #{m[0]} #{input_file_1}` }
# end

guard 'rspec', :cli => '--color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

