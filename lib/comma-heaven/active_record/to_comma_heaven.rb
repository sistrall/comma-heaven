module CommaHeaven
  module ActiveRecord
    module ClassMethods
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
        
        returning FasterCSV::Table.new([]) do |table|
          columns = CommaHeaven::Sqler::Columns.new(self, options[:export])
          headers = columns.sql_as
          
          find(:all, :limit => options[:limit], :joins => columns.joins, :select => columns.select).each do |resource|
            fields = columns.sql_as.inject([]) do |a, f|
              a << resource.send(f)
            end
            
            table << FasterCSV::Row.new(headers, fields)
          end
        end
      end
    end
  end
end