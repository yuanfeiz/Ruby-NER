task :default

desc "Impose pipeline on sogou lexical lib"
task :sogou_pipeline  do
  FileList["db/NE.PER.lex.[ab][a-z]"].each do |file|
    fin = file
    fout = fin + ".result"
    `lib/pipeline.rb gazette --in #{fin} --out #{fout}`
  end
end