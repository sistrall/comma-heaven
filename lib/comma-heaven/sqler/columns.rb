module CommaHeaven
  module Sqler
    class Columns < Array
      attr_accessor :parent, :model, :options, :index
    
      def initialize(model, export, options = {})
        @model    = model
        @export   = export
        @options  = options
        
        # Fill the array
        fill!
        
        # Sort by position
        # sort! { |a, b| a.position <=> b.position }
      end
        
      def select
        map(&:select).reject { |e| e.empty? }.join(', ')
      end
      
      def joins
        map(&:joins).compact.uniq.join(" ").gsub(/\n/, '').squeeze(' ')
      end
      
      def sql_as
        map(&:sql_as).flatten
      end
      
      def table
        model.table_name
      end
      
      def table_alias(method = :pluralize)
        t = case self
          when HasManyColumns, BelongsToColumns, HasOneColumns then association.name.to_s.send(method)
          else table.to_s.send(method)
          end
        
        return prefix + [((parent && parent.parent) ? parent.table_alias(method) : nil), t, index].compact.join('_')
      end
      
      def prefix
        return case self
          when HasManyColumns, BelongsToColumns, HasOneColumns then "_"
          else ''
          end
      end
      
      protected
        def limit 
          (options[:limit] || 1).to_i
        end
        
        def fill!
          each_exportable_column do |column_or_association, position, index, opts|
            self << build_column_or_columns(column_or_association, position, index, opts)
          end
        end
        
        def build_column_or_columns(column_or_association, position, index = nil, opts = {})
          opts = opts.merge(:prefix => self.options[:prefix])
          opts = opts.merge(:index  => index)
          opts = opts.merge(:on     => self.options[:on])
          
          export = opts.delete(:export)
          case
          when @model.column_names.include?(column_or_association.to_s)
            as = opts[:as]
            return ::CommaHeaven::Sqler::Column.new(self, position, column_or_association.to_s, as.blank? ? nil : as)
          when association = @model.reflect_on_association(column_or_association.to_sym)
            klass = "::CommaHeaven::Sqler::#{association.macro.to_s.camelize}Columns".constantize
            return klass.new(association, export, position, self, index, opts)
          else
            raise "Error on #{column_or_association.inspect} on #{model.inspect}"
          end
        end
        
        def each_exportable_column
          @export.to_a.map do |f,o| 
            [f, o.to_a.first.first, o.to_a.first.last]
          end.sort do |a,b|
            a[1] <=> b[1]
          end.each do |column_or_association, position, opts|
            opts.symbolize_keys!
            
            unless opts[:include] == '0'
              association = @model.reflect_on_association(column_or_association.to_sym)
              if association && association.macro == :has_many && opts[:by] != 'row'

                limit = case opts[:limit]
                  when "" then 1
                  when NilClass then 1
                  when Integer then opts[:limit]
                  when String then opts[:limit].to_i
                  else 0
                  end

                1.upto(limit).each do |index|
                  yield column_or_association, position, index - 1, opts
                end
              else    
                yield column_or_association, position, nil, opts
              end
            end
          end
        end
    end
  end
end