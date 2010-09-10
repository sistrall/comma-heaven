$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'fastercsv'

require 'activerecord'

require 'active_support'
require 'actionpack'
require 'action_controller'
require 'action_view'

require 'comma-heaven'

require 'spec'
require 'spec/autorun'

ENV['TZ'] = 'UTC'
Time.zone = 'Eastern Time (US & Canada)'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
# ActiveRecord::Base.establish_connection(:adapter => 'mysql', :database => 'comma_heaven_dev', :encoding => 'utf8', :username => 'root', :password => '') 
ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :gardeners do |t|
    t.string :name
    t.string :surname
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

Spec::Runner.configure do |config|
  config.before(:each) do
    class Gardener < ActiveRecord::Base
      has_many :trees
      has_one :gardener_clone
    end
    
    class GardenerClone < ActiveRecord::Base
      belongs_to :gardener_clone
    end
    
    class Tree < ActiveRecord::Base
      belongs_to :gardener
      has_many :leafs, :dependent => :destroy
      
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
end
