module NLP
  def chomp_bracket!(contact_words = true)
    self.gsub!('}{', '} {')
    capture_bracket_regexp = /\{(.*?)\}/
    self.gsub!(capture_bracket_regexp) do
      if contact_words then
        $1.tr(' ', '')
      else
        $1
      end
    end
  end

  def linerize!
    self.gsub!(' ', "\n")
  end

  def to_crf_input!
    self.gsub!('#', ' ')
  end

  def to_cardinal
    case self
    when 'nr'
      'PER'
    when 'nt'
      'ORG'
    when 'ns'
      'LOC'
    when 'nz'
      'BRI'
    end
  end
end

class String
  include NLP
end