module CommaHeaven
  module Sqler
    class HasOneColumns < AssociationColumns
      def join_clause
        <<-EOS
        LEFT JOIN #{quote(table)} AS #{table_alias}
          ON #{parent.table_alias}.#{model.primary_key} = #{table_alias}.#{foreign_key_for(association)}
        EOS
      end
    end
  end
end