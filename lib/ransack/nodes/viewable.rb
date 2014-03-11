module Ransack
  module Nodes
    class Viewable < Node
      attr_reader :attr, :table, :field

      class << self
        def extract(context, str)
          field = context.contextualize(str)
          table = ActiveRecord::Base.send(:descendants).detect { |m| m.table_name == field.relation.name }
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

    end
  end
end