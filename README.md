# Directory Tree:
```
  NLP/
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
  $ cd NLP
  $ bundle --without development
  $ ruby pipeline.rb /path/to/input/file
```

# Note
我对`stanford-postagger.sh`做了小修改，请用修改后的版本。（主要是修正了`-classpath`）