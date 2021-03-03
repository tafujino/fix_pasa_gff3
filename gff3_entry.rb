# frozen_string_literal

class Gff3Entry
  TYPE_COL_INDEX = 2
  START_COL_INDEX = 3
  END_COL_INDEX = 4
  ATTRIBUTE_COL_INDEX = 8

  # @return [Array<String>]
  attr_reader :mandatory_fields

  # @return [Hash { Symbol => String }]
  attr_reader :attributes

  # @param mandatory_fields [Array<String>]
  # @param attributes       [Hash { Symbol => String }]
  def initialize(mandatory_fields, attributes)
    @mandatory_fields = mandatory_fields
    @attributes = attributes
  end

  # @return [Integer]
  def start_pos
    @mandatory_fields[START_COL_INDEX].to_i
  end

  # @return [Integer]
  def end_pos
    @mandatory_fields[END_COL_INDEX].to_i
  end

  # @return [String]
  def to_s
    attr_field = @attributes.map { |k, v| "#{k}=#{v}" }.join(';')
    (@mandatory_fields + [attr_field]).join("\t")
  end

  class << self
    # @param line [String]
    # @return     [Gff3Entry]
    def parse(line)
      fields = line.split("\t")
      attributes = parse_attributes(fields[ATTRIBUTE_COL_INDEX])
      Gff3Entry.new(fields[0...ATTRIBUTE_COL_INDEX], attributes)
    end

    private

    # @param field [String, nil]
    # @return      [Hash{ Symbol => String }]
    def parse_attributes(field)
      return {} unless field

      field.split(';').map.to_h do |kv|
        unless kv =~ /^([^=]+)=([^=]+)$/
          warn "failed to parse attribute key-value: #{kv}"
          exit 1
        end

        [$1.to_sym, $2]
      end
    end
  end
end
