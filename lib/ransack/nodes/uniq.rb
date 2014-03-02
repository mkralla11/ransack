module Ransack
  module Nodes
    class Uniq < Viewable

      def group_by_statement
        @table + "." + @field
      end

    end
  end
end