require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "BelongsToColumns" do
  before(:each) do
    @leaf = CommaHeaven::Sqler::Columns.new(Leaf, {})
    @association = Leaf.reflect_on_association(:tree)
  end
  
  it "should build correct SQL select clause" do
    column = CommaHeaven::Sqler::BelongsToColumns.new(@association, {:age => {4 => {:include => '1', :as => ''}}}, 1, @leaf)
    column.select.should == "_trees.age AS \"tree_age\""
  end

  it "should build correct SQL joins clause" do
    column = CommaHeaven::Sqler::BelongsToColumns.new(@association, {:age => {4 => {:include => '1', :as => ''}}}, 1, @leaf)
    column.joins.should == <<-EOS.gsub(/\n/, ' ').squeeze(' ').strip
LEFT JOIN "trees" AS _trees
 ON _trees.id = leaves.tree_id
EOS
  end
end
