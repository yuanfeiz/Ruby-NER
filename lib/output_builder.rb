require 'builder'

class OutputBuilder
    def intialize(offsets)
        @offsets = offsets
        @xml = nil
    end

    def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

        @xml = builder.EntityExtraction do |entity_extraction|
            entity_extraction.Entitie0s(count: @offsets.size) do |entities|
                @offsets.each do |offset|
                    entities.Entity(type: offset[0]) do |entity|
                        entity.Text(offset[3])
                        entity.Doc(offset[1])
                        entity.Start(offset[2])
                    end
                end
            end
        end
    end

    def write_to_file(path)
        File.open(path, "w") { |io| io.write(self.to_xml) }
    end
end