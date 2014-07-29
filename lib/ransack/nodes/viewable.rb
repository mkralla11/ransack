module Ransack
  module Nodes
    class Viewable < Node
      attr_reader :attr, :table, :field

      class << self
        def extract(context, attr)
          field = context.contextualize(attr.name)
          table =  attr.context.klassify(attr)
          self.new(context).build(:attr=>attr, :table=>table, :field=>field)
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