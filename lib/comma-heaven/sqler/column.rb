require 'active_support/core_ext'

module CommaHeaven
  module Sqler
    class Column < Struct.new(:parent, :position, :attribute, :as)
      delegate :association, :model, :table, :table_alias, :index, :join_clause, :to => :parent
      
      def select
        "#{table_alias}.#{attribute} AS #{quote(sql_as)}"
      end
      
      def joins
        sql = join_clause
        sql << " AND #{table_alias}.#{association.klass.primary_key} IN (SELECT #{association.klass.primary_key} FROM #{association.quoted_table_name} WHERE #{model.send(:sanitize_sql, association.options[:conditions])})" if parent.respond_to?(:association) && association.options[:conditions]
        sql.gsub(/\n/, '').squeeze(' ').strip
      end
      
      def sql_as
        return as % index if as
        return [table_alias(:singularize).gsub(/^_+/, ''), attribute].compact.join('_')
      end

      protected
        def quote(string)
          ::ActiveRecord::Base.connection.quote_column_name(string)
        end
        
    end
  end
end