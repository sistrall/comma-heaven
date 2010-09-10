require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "HasOneColumns" do
  before(:each) do
    @gardener = CommaHeaven::Sqler::Columns.new(Gardener, {})
    @association = Gardener.reflect_on_association(:gardener_clone)
  end
  
  it "should build correct SQL select clause" do
    column = CommaHeaven::Sqler::HasOneColumns.new(@association, {:name => {4 => {:include => '1', :as => ''}}}, 1, @gardener)
    column.select.should == "gardener_clones.name AS \"gardener_clone_name\""
  end

  it "should build correct SQL joins clause" do
    column = CommaHeaven::Sqler::HasOneColumns.new(@association, {:name => {4 => {:include => '1', :as => ''}}}, 1, @gardener)
    column.joins.should == <<-EOS.gsub(/\n/, ' ').squeeze(' ').strip
LEFT JOIN "gardener_clones" AS gardener_clones
 ON gardeners.id = gardener_clones.gardener_id
EOS
  end
end
