module Ransack
  module Nodes
    class Display < Node
      attr_reader :attr, :table, :field

      class << self
        def extract(context, str)
          ar_col = context.contextualize(str)
          table = ar_col.relation.name
          field = ar_col.name
          self.new(context).build(:attr=>str, :table=>table, :field=>field)
        end
      end

      def build(params)
        params.with_indifferent_access.each do |key, value|
          if key.match(/^(attr|table|field)$/)
            self.send("#{key}=", value)
          end
        end

        self
      end

      def attr=(attr)
        @attr = attr
      end


      def table=(table)
        @table = table
      end

      def field=(field)
        @field = field
      end


      def select_statement
        @table + "." + @field + " as " + @attr
      end

    end
  end
end