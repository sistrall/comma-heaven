module CommaHeaven
  module Sqler
    class BelongsToColumns < AssociationColumns
      def join_clause
        <<-EOS
        LEFT JOIN #{quote(table)} AS #{table_alias}
          ON #{table_alias}.#{model.primary_key} = #{parent.table_alias}.#{association.primary_key_name}
        EOS
      end
    end
  end
end