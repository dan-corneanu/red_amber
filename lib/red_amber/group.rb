# frozen_string_literal: true

module RedAmber
  # group class
  class Group
    def initialize(dataframe, *group_keys)
      @dataframe = dataframe
      @table = @dataframe.table
      @group_keys = group_keys.flatten

      raise GroupArgumentError, 'group_keys is empty.' if @group_keys.empty?

      d = @group_keys - @dataframe.keys
      raise GroupArgumentError, "#{d} is not a key of\n #{@dataframe}." unless d.empty?

      @group = @table.group(*@group_keys)
    end

    functions = %i[count sum product mean min max stddev variance]
    functions.each do |function|
      define_method(function) do |*summary_keys|
        by(function, summary_keys)
      end
    end

    def inspect
      tallys = @dataframe.pick(@group_keys).vectors.map.with_object({}) do |v, h|
        h[v.key] = v.tally
      end
      "#<#{self.class}:#{format('0x%016x', object_id)}\n#{tallys}>"
    end

    private

    def by(func, summary_keys)
      summary_keys = Array(summary_keys).flatten
      d = summary_keys - @dataframe.keys
      raise GroupArgumentError, "#{d} is not a key of\n #{@dataframe}." unless summary_keys.empty? || d.empty?

      RedAmber::DataFrame.new(@group.send(func, *summary_keys))
    end
  end
end
