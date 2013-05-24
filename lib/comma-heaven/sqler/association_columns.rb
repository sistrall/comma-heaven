module CommaHeaven
  module Sqler
    class AssociationColumns < Columns
      attr_accessor :position, :association

      # @parent@ is the parameter for passing a reference to the 
      # containing columns array
      def initialize(association, export, position, parent, index = nil, options = {})
        self.parent = parent
        self.position = position
        self.association = association
        self.index = index
        super(association.klass, export, options)
      end

      def foreign_key_for(an_association)
        an_association.respond_to?(:foreign_key) ? an_association.foreign_key : an_association.primary_key_name
      end

      def table_alias(method = :pluralize)
        t = association.name.to_s.send(method)
        
        return prefix + [((parent && parent.parent) ? parent.table_alias(method) : nil), t, index].compact.join('_')
      end

      def prefix
        return "_"
      end
    end
  end
end