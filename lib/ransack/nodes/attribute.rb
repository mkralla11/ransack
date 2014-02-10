module Ransack
  module Nodes
    class Attribute < Node
      include Bindable

      attr_reader :name
      # attr_accessor :eval_attribute, :display, :field
      attr_accessor :display

      delegate :blank?, :present?, :==, :to => :name
      delegate :engine, :to => :context


      def initialize(context, name = nil, display=nil)
        super(context)
        self.name = name unless name.blank?
        #self.eval_attribute, self.field = attribute_to_eval_string(name) 
        self.display = display
      end

      def name=(name)
        @name = name
        context.bind(self, name) unless name.blank?
      end

      def valid?
        bound? && attr
      end

      def type
        if ransacker
          return ransacker.type
        else
          context.type_for(self)
        end
      end

      def eql?(other)
        self.class == other.class &&
        self.name == other.name
      end
      alias :== :eql?

      def hash
        self.name.hash
      end

      def persisted?
        false
      end

      def inspect
        "Attribute <#{name}>, Display <#{display}>"
      end


    end
  end
end