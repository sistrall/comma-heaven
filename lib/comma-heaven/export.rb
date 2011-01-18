module CommaHeaven
  class Export
    module Implementation
      def export(options = {})
        Export.new(self, scope(:find), options)
      end
    end
    
    attr_accessor :klass, :current_scope, :options, :export, :limit, :by
    undef :id if respond_to?(:id)
  
    def initialize(klass, current_scope, options = {})
      self.klass = klass
      self.current_scope = current_scope
      self.options = options || {}
      
      self.options.symbolize_keys!
      
      self.export = self.options[:export] || {}
      
      self.export.symbolize_keys!
      
      self.limit = self.options[:limit]
    end
    
    def save(options = {})
      all_options = self.options.merge(options)
      
      csv_options = all_options.slice(*FasterCSV::DEFAULT_OPTIONS.keys)
      tch_options = all_options.except(*FasterCSV::DEFAULT_OPTIONS.keys) # TCH means To Comma Heaven
      
      klass.scoped(current_scope).to_comma_heaven(tch_options.symbolize_keys).to_csv(csv_options.symbolize_keys)
    end

    private
      def method_missing(name, *args, &block)
        case 
        when column_name?(name)
          return OpenStruct.new(export[name].values.first) rescue OpenStruct.new({})
        when association_name?(name)
          return self.class.new(klass.reflect_on_association(name).klass, {}, export[name].values.first) rescue self.class.new(klass.reflect_on_association(name).klass, {}, {})
        else
          return super
        end
      end
      
      def column_name?(value)
        klass.column_names.include?(value.to_s)
      end
      
      def association_name?(value)
        klass.reflect_on_all_associations.map(&:name).include?(value.to_sym)
      end
  end
end