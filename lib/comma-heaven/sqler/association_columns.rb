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
    end
  end
end