module Ransack
  module Nodes
    class Display < Viewable

      def select_statement
        @table + "." + @field + " as " + @attr
      end

    end
  end
end