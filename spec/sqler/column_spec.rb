require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Column" do
  before(:each) do
    @columns = double(:@columns)
    @columns.stub(:model).and_return(Gardener)
    @columns.stub(:table).and_return('gardeners')
  end
  
  it "should build correct SQL select clause" do
    @columns.stub(:index).and_return(nil)
    @columns.stub(:table_alias).with(:singularize).and_return('gardener')
    @columns.stub(:table_alias).with().and_return('gardeners')
    column = CommaHeaven::Sqler::Column.new(@columns, 1, 'name', nil)
    column.select.should == 'gardeners.name AS `gardener_name`'
  end

  it "should allow exclicit aliasing" do
    @columns.stub(:index).and_return(nil)
    @columns.stub(:table_alias).and_return('gardeners')
    column = CommaHeaven::Sqler::Column.new(@columns, 1, 'name', 'as')
    column.select.should == 'gardeners.name AS `as`'
  end
end
