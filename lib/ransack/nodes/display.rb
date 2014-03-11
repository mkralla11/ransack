module Ransack
  module Nodes
    class Display < Viewable

      def select_statement
        if @table._ransackers.has_key?( @field.name )
        # check if we should use the 'ransacker' virtual attribute
          aggregate_column
        elsif @table.ransackable_attributes.include?( @field.name )
        # check if it is a searchable column before allowing the select
          existing_column
        end
      end

      def aggregate_column
        @table._ransackers[@field.name].call(@callable).try(:to_s) + " as " + @attr
      end

      def existing_column
        @table.table_name + "." + @field.name + " as " + @attr
      end

    end
  end
end