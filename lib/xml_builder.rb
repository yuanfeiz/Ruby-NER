# encoding: utf-8
require 'builder'

module XmlBuilder
  # input format: 湖南 NN AA
  #               毛泽东 NR BB
  #               EOP
  #               本报 NR AA
  #               ...
  # note: EOP represents 'end of paragraph'
  def to_xml
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

    @xml = builder.EntityExtraction do |entity_extraction|
      entity_extraction.Entities(count: entities.size) do |local_entities|
        entities.each do |offset|
          local_entities.Entity(type: offset[0]) do |entity|
            entity.Text(offset[3])
            entity.Doc(offset[1])
            entity.Start(offset[2])
          end
        end
      end
    end
  end

  def entities
    return @entities if @entities

    @entities = []

    self.split(/^EOP.*?$/).each_with_index do |para, para_index|
      para.strip.split("\n").inject(0) do |offset, this_line|
        word = this_line.split.first
        tag = this_line.split.last

        if tag.start_with? 'B' then
          @entities.push [output_format(tag), para_index + 1, offset, word]
        elsif tag.start_with? 'I' then
          @entities.last[-1] += word
        end

        offset + word.length
      end
    end

    @entities
  end

private
  def output_format(tag)
    if tag.end_with? 'PER' then
      'nr'
    elsif tag.end_with? 'LOC' then
      'ns'
    elsif tag.end_with? 'ORG' then
      'nt'
    end
  end

end