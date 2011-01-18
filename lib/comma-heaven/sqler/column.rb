module CommaHeaven
  module Sqler
    class Column < Struct.new(:parent, :position, :attribute, :as)
      delegate :association, :model, :table, :table_alias, :index, :to => :parent
      
      def select
        "#{table_alias}.#{attribute} AS #{quote(sql_as)}"
      end
      
      def joins
        case parent
        when HasManyColumns
          if parent.options[:by] == 'row'
            <<-EOS
            LEFT JOIN #{quote(table)} AS #{table_alias}
              ON #{parent.parent.table_alias}.#{model.primary_key} = #{table_alias}.#{association.primary_key_name}
            EOS
          else
            <<-EOS
            LEFT JOIN #{quote(table)} AS #{table_alias}
              ON #{parent.parent.table_alias}.#{model.primary_key} = #{table_alias}.#{association.primary_key_name}
              AND #{table_alias}.#{association.klass.primary_key} = (SELECT #{association.klass.primary_key} FROM #{association.quoted_table_name} WHERE #{association.primary_key_name} = #{parent.parent.table_alias}.#{model.primary_key} LIMIT #{index}, 1)
            EOS
          end
        when BelongsToColumns
          <<-EOS
          LEFT JOIN #{quote(table)} AS #{table_alias}
            ON #{table_alias}.#{model.primary_key} = #{parent.parent.table_alias}.#{association.primary_key_name}
          EOS
        when HasOneColumns
          <<-EOS
          LEFT JOIN #{quote(table)} AS #{table_alias}
            ON #{parent.parent.table_alias}.#{model.primary_key} = #{table_alias}.#{association.primary_key_name}
          EOS
        else ''
        end.gsub(/\n/, '').squeeze(' ').strip
      end
      
      def sql_as
        return as % index if as
        return [table_alias(:singularize), attribute].compact.join('_')
      end

      protected
        def quote(string)
          ::ActiveRecord::Base.connection.quote_column_name(string)
        end
        
    end
  end
end