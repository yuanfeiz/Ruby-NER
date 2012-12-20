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
  $ lib/pipeline.rb test --in [INPUT_FILE] --output [OUTPUT_FILE] --model [MODEL_FILE]


  # Utils - 用法参见lib/pipeline.rb help [COMMAND]
  $ lib/pipeline.rb check_column_size # 检查每行feature数量是否一致。
  $ lib/pipeline.rb sub_label # 替换标签
  $ lib/pipeline.rb extract_prefix_and_surfix
```

# Note
我对`stanford-postagger.sh`做了小修改，请用修改后的版本。（主要是修正了`-classpath`）