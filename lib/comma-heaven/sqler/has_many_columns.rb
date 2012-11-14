module CommaHeaven
  module Sqler
    class HasManyColumns < AssociationColumns
      def join_clause
        # @:through@ relantionships requires special treatment: 
        # the JOIN must walk through 2 table 
        join = if association.options[:through]
          <<-EOS
            LEFT JOIN #{association.through_reflection.table_name} AS _#{association.through_reflection.table_name}#{table_alias}
              ON #{parent.table_alias}.#{model.primary_key} = _#{association.through_reflection.table_name}#{table_alias}.#{foreign_key_for(association.through_reflection)}
            LEFT JOIN #{quote(table)} AS #{table_alias}
              ON _#{association.through_reflection.table_name}#{table_alias}.#{model.primary_key} = #{table_alias}.#{association.through_reflection.association_foreign_key}
          EOS
        else
          <<-EOS
            LEFT JOIN #{quote(table)} AS #{table_alias}
              ON #{parent.table_alias}.#{model.primary_key} = #{table_alias}.#{foreign_key_for(association)}
          EOS
        end

        unless options[:by] == 'row'
          join += ' ' + if association.options[:through]
            <<-EOS
              AND #{table_alias}.#{association.klass.primary_key} = 
                ( SELECT #{association.quoted_table_name}.#{association.klass.primary_key} 
                  FROM #{association.quoted_table_name} 
                  JOIN #{association.through_reflection.table_name} ON #{association.quoted_table_name}.#{association.through_reflection.association_foreign_key} = #{association.through_reflection.table_name}.#{association.through_reflection.klass.primary_key}
                  WHERE #{foreign_key_for(association.through_reflection)} = #{parent.table_alias}.#{model.primary_key} 
                  LIMIT #{index}, 1 )
            EOS
          else
            <<-EOS
              AND #{table_alias}.#{association.klass.primary_key} = (SELECT #{association.klass.primary_key} FROM #{association.quoted_table_name} WHERE #{foreign_key_for(association)} = #{parent.table_alias}.#{model.primary_key} LIMIT #{index}, 1)
            EOS
          end
        end

        join
      end
    end
  end
end