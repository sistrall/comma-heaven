require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "HasManyColumns" do
  before(:each) do
    @tree = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}})
    @association = Tree.reflect_on_association(:leafs)
  end
  
  it "should build correct SQL select clause" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.select.should == 'leafs_1.position AS "leaf_1_position"'
  end

  it "should build correct SQL select clause for multiple fields" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}, :size => {5 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.select.should == 'leafs_1.position AS "leaf_1_position", leafs_1.size AS "leaf_1_size"'
  end
  
  it "should build correct SQL joins clause" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.joins.should == <<-EOS.gsub(/\n/, ' ').squeeze(' ').strip
LEFT JOIN "leafs" AS leafs_1
  ON trees.id = leafs_1.tree_id
  AND leafs_1.id = (SELECT id FROM "leafs" WHERE tree_id = trees.id LIMIT 1, 1)
EOS
  end
end
