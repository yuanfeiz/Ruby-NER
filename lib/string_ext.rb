module NLP
  def chomp_bracket!
    self.gsub!('}{', '} {')
    capture_bracket_regexp = /\{(.*?)\}/
    self.gsub!(capture_bracket_regexp) do
      $1.tr(' ', '')
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
    end
  end
end

class String
  include NLP
end