module Ransack
  module Nodes
    class Uniq < Viewable

      def group_by_statement
        if @table._ransackers.has_key?( @field.name )
        # check if we should use the 'ransacker' virtual attribute
          aggregate_column
        elsif ransackable_attributes.include?( @field.name )
        # check if it is a searchable column before allowing the group_by
          existing_column
        end
      end

      def aggregate_column
        @table._ransackers[@field.name].call(@callable).try(:to_s)
      end

      def existing_column
        @table.table_name + "." + @field.name
      end


    end
  end
end