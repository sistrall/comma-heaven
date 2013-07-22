module CommaHeaven
  module ActiveRecord
    module ClassMethods
      module Rails3
        def self.extended(base)
          base.class_eval do
            base.class_attribute :comma_heaven_columns
            base.comma_heaven_columns = []
            
            base.class_attribute :comma_heaven_associations
            base.comma_heaven_associations = []
          end
        end
        
        def to_comma_heaven(options = {})
          options.symbolize_keys!
          options[:limit] = options[:limit].to_i if options[:limit].kind_of?(String)
          options[:converter] ||= lambda { |v| v }
          
          FasterCSV::Table.new([]).tap do |table|
            columns = CommaHeaven::Sqler::Columns.new(self, options[:export])
            headers = columns.sql_as

            ids = select("#{table_name}.#{primary_key}").limit(options[:limit]).all.map(&:id)
            
            unscoped do
              where(["#{columns.table_alias}.#{primary_key} IN (?)", ids]).limit(options[:limit]).joins(columns.joins).select(columns.select).all.each do |resource|
                fields = columns.sql_as.inject([]) do |acc, field|
                  value = resource.send(field)
                  
                  if options[:format]
                    begin 
                      value = value.to_time.strftime(options[:format][:datetime]) if value =~ %r{^(\d{4,4})-(\d{2,2})-(\d{2,2})} && options[:format][:datetime]
                    rescue 
                    end
                  end
                  
                  acc << options[:converter].call(value)
                end
                
                table << FasterCSV::Row.new(headers, fields)
              end
            end
          end
        end
      end

      module Rails2
        def self.extended(base)
          base.class_eval do
            base.class_inheritable_accessor :comma_heaven_columns
            base.comma_heaven_columns = []
            
            base.class_inheritable_accessor :comma_heaven_associations
            base.comma_heaven_associations = []
          end
        end
        
        def to_comma_heaven(options = {})
          options.symbolize_keys!
          options[:limit] = options[:limit].to_i if options[:limit].kind_of?(String)
          options[:converter] ||= lambda { |v| v }
          
          FasterCSV::Table.new([]).tap do |table|
            columns = CommaHeaven::Sqler::Columns.new(self, options[:export])
            headers = columns.sql_as

            ids = find(:all, :select => "#{table_name}.#{primary_key}", :limit => options[:limit]).map(&:id)
            
            with_exclusive_scope do
              find(:all, :conditions => ["#{columns.table_alias}.#{primary_key} IN (?)", ids], :limit => options[:limit], :joins => columns.joins, :select => columns.select).each do |resource|
                fields = columns.sql_as.inject([]) do |acc, field|
                  value = resource.send(field)
                  
                  if options[:format]
                    begin 
                      value = value.strftime(options[:format][:datetime]) if (value.is_a?(Date) || value.is_a?(Time)) && options[:format][:datetime]
                    rescue 
                    end
                  end
                  
                  acc << options[:converter].call(value)
                end
                
                table << FasterCSV::Row.new(headers, fields)
              end
            end
          end
        end
      end

      Rails1 = Rails2
    end
  end
end