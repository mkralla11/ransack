require 'ransack/nodes'
require 'ransack/context'
require 'ransack/naming'

module Ransack
  class Search
    include Naming

    attr_reader :base, :context


    delegate :object, :klass, :to => :context
    delegate :new_grouping, :new_condition,
             :build_grouping, :build_condition,
             :translate, :to => :base

    def initialize(object, params = {}, options = {})
      @display_attrs = []
      @uniq_attrs = []

      params = {} unless params.is_a?(Hash)
      (params ||= {})
      .delete_if { |k, v| [*v].all? { |i| i.blank? && i != false } }
      @context = Context.for(object, options)
      @context.auth_object = options[:auth_object]
      @base = Nodes::Grouping.new(@context, 'and')
      build(params.with_indifferent_access)
      recurse_hash_to_find_viewables(params.with_indifferent_access)
      build_displays
      build_uniqs
    end

    def result(opts = {})
      @context.evaluate(self, opts)
    end

    def build(params)
      collapse_multiparameter_attributes!(params).each do |key, value|
        if ['s', 'sorts'].include?(key)
          send("#{key}=", value)
        elsif base.attribute_method?(key)
          base.send("#{key}=", value)
        elsif !Ransack.options[:ignore_unknown_conditions]
          raise ArgumentError, "Invalid search term #{key}"
        end
      end
      self
    end

    def build_displays
      @display_attrs.each do |name|
        displays << Nodes::Display.extract(@context, name)
      end
    end

    def build_uniqs
      @uniq_attrs.each do |name|
        uniqs << Nodes::Uniq.extract(@context, name)
      end
    end

    def displays
      @displays ||= []
    end
    alias :d :displays

    def uniqs
      @uniqs ||= []
    end
    alias :u :uniqs


    def recurse_hash_to_find_viewables(obj)
      if obj.is_a?(Hash)
        obj.each_pair do |key, value|
          if key == "d" and value == "1"
            @display_attrs << obj['a']['0']['name'] if obj.try(:[], 'a').try(:[], '0').try(:[], 'name').present?
          elsif key == "u" and value == "1"
            @uniq_attrs << obj['a']['0']['name'] if obj.try(:[], 'a').try(:[], '0').try(:[], 'name').present?
          else
            recurse_hash_to_find_viewables(value)
          end
        end
      end
    end

    def headers
      @headers ||= displays.collect do |disp|
        {
          :humanize=>(disp.table.table_name + "_" + disp.field.name).titleize,
          :attribute=>disp.attr
        }
      end
    end


    def sorts=(args)
      case args
      when Array
        args.each do |sort|
          if sort.kind_of? Hash
            sort = Nodes::Sort.new(@context).build(sort)
          else
            sort = Nodes::Sort.extract(@context, sort)
          end
          self.sorts << sort
        end
      when Hash
        args.each do |index, attrs|
          sort = Nodes::Sort.new(@context).build(attrs)
          self.sorts << sort
        end
      when String
        self.sorts = [args]
      else
        raise ArgumentError,
        "Invalid argument (#{args.class}) supplied to sorts="
      end
    end
    alias :s= :sorts=

    def sorts
      @sorts ||= []
    end
    alias :s :sorts

    def build_sort(opts = {})
      new_sort(opts).tap do |sort|
        self.sorts << sort
      end
    end

    def new_sort(opts = {})
      Nodes::Sort.new(@context).build(opts)
    end

    def method_missing(method_id, *args)
      method_name = method_id.to_s
      writer = method_name.sub!(/\=$/, '')
      if base.attribute_method?(method_name)
        base.send(method_id, *args)
      else
        super
      end
    end

    def inspect
      "Ransack::Search<class: #{klass.name}, base: #{base.inspect}>"
    end

    private

    def collapse_multiparameter_attributes!(attrs)
      attrs.keys.each do |k|
        if k.include?("(")
          real_attribute, position = k.split(/\(|\)/)
          cast = %w(a s i).include?(position.last) ? position.last : nil
          position = position.to_i - 1
          value = attrs.delete(k)
          attrs[real_attribute] ||= []
          attrs[real_attribute][position] = if cast
            (value.blank? && cast == 'i') ? nil : value.send("to_#{cast}")
          else
            value
          end
        elsif Hash === attrs[k]
          collapse_multiparameter_attributes!(attrs[k])
        end
      end

      attrs
    end

  end
end
