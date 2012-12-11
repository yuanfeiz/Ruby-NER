# Directory Tree:
```
  Ruby-NER/
  	lib/
	  pipeline.rb
    stanford-segmenter-2012-11-11/
      test.simp.utf8
      segment.sh
    stanford-postagger-full-2012-11-11/
      models/
      stanford-postagger.sh
```

# Usage
```
  $ cd Ruby-NER
  $ bundle --without development
  $ lib/pipeline.rb pipeline --in [INPUT_FILE] --output [OUTPUT_FILE] --slice-size [SIZE]

  $ lib/pipeline.rb check_column_size --in [INPUT] # 检查每行feature数量是否一致。

  # 查看帮助
  # lib/pipeline.rb
```

# Note
我对`stanford-postagger.sh`做了小修改，请用修改后的版本。（主要是修正了`-classpath`）