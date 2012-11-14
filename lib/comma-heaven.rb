require RUBY_VERSION > "1.9" ? "csv" : 'fastercsv'

if RUBY_VERSION > "1.9"
  FasterCSV = CSV
end

require 'active_record'

require 'comma-heaven/active_record/to_comma_heaven'
require 'comma-heaven/sqler'
require 'comma-heaven/sqler/column'
require 'comma-heaven/sqler/columns'
require 'comma-heaven/sqler/association_columns'
require 'comma-heaven/sqler/has_one_columns'
require 'comma-heaven/sqler/has_many_columns'
require 'comma-heaven/sqler/belongs_to_columns'
require 'comma-heaven/export'

ActiveRecord::Base.send(:extend, CommaHeaven::Export::Implementation)

case ActiveRecord::VERSION::MAJOR
when 1 then ActiveRecord::Base.send(:extend, CommaHeaven::ActiveRecord::ClassMethods::Rails1)
when 2 then ActiveRecord::Base.send(:extend, CommaHeaven::ActiveRecord::ClassMethods::Rails2)
else        ActiveRecord::Base.send(:extend, CommaHeaven::ActiveRecord::ClassMethods::Rails3)
end
