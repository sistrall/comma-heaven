require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "HasManyColumns" do
  before(:each) do
    @tree = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}})
    @association = Tree.reflect_on_association(:leafs)
  end
  
  it "should build correct SQL select clause" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.select.should == '_leafs_1.position AS "leaf_1_position"'
  end

  it "should build correct SQL select clause for multiple fields" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}, :size => {5 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.select.should == '_leafs_1.position AS "leaf_1_position", _leafs_1.size AS "leaf_1_size"'
  end
  
  it "should build correct SQL joins clause" do
    column = CommaHeaven::Sqler::HasManyColumns.new(@association, {:position => {4 => {:include => '1', :as => ''}}}, 1, @tree, 1, :limit => '3')
    column.joins.should == <<-EOS.gsub(/\n/, ' ').squeeze(' ').strip
LEFT JOIN "leaves" AS _leafs_1
  ON trees.id = _leafs_1.tree_id
  AND _leafs_1.id = (SELECT id FROM "leaves" WHERE tree_id = trees.id LIMIT 1, 1)
EOS
  end

  it 'should build correct SQL joins clause for has_many :through relationship' do
    @gardener = CommaHeaven::Sqler::Columns.new(Gardener, { :name  => {0 => {}},
                                                            :leafs => {1 => {:export => { 
                                                              :position           => {0 => {}},
                                                              :height_from_ground => {1 => {}} } } } })
    column = CommaHeaven::Sqler::HasManyColumns.new(Gardener.reflect_on_association(:leafs), {:position => {4 => {:include => '1', :as => ''}}}, 1, @gardener, 0, :limit => '3')
    column.joins.should == <<-EOS.gsub(/\n/, ' ').squeeze(' ').strip
LEFT JOIN trees AS _trees_leafs_0 
  ON gardeners.id = _trees_leafs_0.gardener_id 
LEFT JOIN "leaves" AS _leafs_0 
  ON _trees_leafs_0.id = _leafs_0.tree_id 
  AND _leafs_0.id = 
    ( SELECT "leaves".id 
      FROM "leaves" 
      JOIN trees ON "leaves".tree_id = trees.id 
      WHERE gardener_id = gardeners.id LIMIT 0, 1 )
EOS
  end
end
