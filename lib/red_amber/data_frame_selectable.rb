# frozen_string_literal: true

module RedAmber
  # mix-ins for the class DataFrame
  module DataFrameSelectable
    # select columns: [symbol] or [string]
    # select rows: [array of index], [range]
    def [](*args)
      raise DataFrameArgumentError, 'Empty dataframe' if empty?
      raise DataFrameArgumentError, 'Empty argument' if args.empty?

      # expand Range like [1..3, 4] to [1, 2, 3, 4]
      expanded =
        args.each_with_object([]) do |e, a|
          e.is_a?(Range) ? a.concat(e.to_a) : a.append(e)
        end

      return select_rows(expanded) if integers?(expanded)
      return select_columns(expanded.map(&:to_sym)) if sym_or_str?(expanded)

      raise DataFrameArgumentError, "invalid argument #{args}"
    end

    def head(n_rows = 5)
      raise DataFrameArgumentError, "index is out of range #{n_rows}" if n_rows.negative?

      self[0...[n_rows, size].min]
    end

    def tail(n_rows = 5)
      raise DataFrameArgumentError, "index is out of range #{n_rows}" if n_rows.negative?

      self[-[n_rows, size].min..-1]
    end

    def first(n_rows = 1)
      head(n_rows)
    end

    def last(n_rows = 1)
      tail(n_rows)
    end

    private # =====

    def select_columns(keys)
      DataFrame.new(@table[keys])
    end

    def select_rows(indeces)
      if out_of_range?(indeces)
        raise DataFrameArgumentError, "invalid index: #{indeces} for [0..#{size - 1}]"
      end

      a = indeces.map { |i| @table.slice(i).to_a }
      DataFrame.new(@table.schema, a)
    end

    def out_of_range?(indeces)
      indeces.max >= size || indeces.min < -size
    end

    def integers?(enum)
      enum.all?(Integer)
    end

    def sym_or_str?(enum)
      enum.all? { |e| e.is_a?(Symbol) || e.is_a?(String) }
    end
  end
end