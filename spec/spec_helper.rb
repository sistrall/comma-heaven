require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'comma-heaven'

ENV['TZ'] = 'UTC'
Time.zone = 'Eastern Time (US & Canada)'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
# ActiveRecord::Base.establish_connection(:adapter => "mysql2", :database => "comma-heaven-test", :user => 'root', :password => '')
ActiveRecord::Base.configurations = true
# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.verbose = false

RSpec.configure do |config|
  config.before(:all) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :gardeners do |t|
        t.string :name
        t.string :surname
        t.datetime :birthdate
      end
      
      create_table :gardener_clones do |t|
        t.integer :gardener_id
        t.string :name
        t.string :surname
      end
      
      create_table :trees do |t|
        t.string :name
        t.integer :age
        t.integer :gardener_id
      end
      
      create_table :leafs do |t|
        t.integer :tree_id
        t.string :position
        t.float :size
        t.float :height_from_ground
      end
      
      create_table :cells do |t|
        t.integer :leaf_id
        t.float :weight
        t.float :lat
        t.float :lng
      end
    end
  end

  config.before(:each) do
    class Gardener < ActiveRecord::Base
      has_many :trees
      has_many :leafs, :through => :trees
      has_one :gardener_clone
    end
    
    class GardenerClone < ActiveRecord::Base
      belongs_to :gardener_clone
    end
    
    class Tree < ActiveRecord::Base
      belongs_to :gardener
      has_many :leafs, :dependent => :destroy
      has_many :matching_o_leafs, :class_name => 'Leaf', :conditions => ['position LIKE ?', '%o%']
      
      named_scope :that_begins_with_o, {:conditions => ['name LIKE ?', 'o%']}
    end

    class Leaf < ActiveRecord::Base
      belongs_to :tree
      has_many :cells
    end
    
    class Cell < ActiveRecord::Base
      belongs_to :leaf
    end
    
    Gardener.destroy_all
    GardenerClone.destroy_all
    Tree.destroy_all
    Leaf.destroy_all
    Cell.destroy_all
  end
  
  config.after(:each) do
    Object.send(:remove_const, :Gardener)
    Object.send(:remove_const, :Tree)
    Object.send(:remove_const, :Leaf)
    Object.send(:remove_const, :Cell)
  end

  config.after(:all) do
    ActiveRecord::Schema.define(:version => 2) do
      drop_table :gardeners
      drop_table :gardener_clones
      drop_table :trees
      drop_table :leafs
      drop_table :cells
    end
  end
end
