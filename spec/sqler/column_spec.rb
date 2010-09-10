require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Column" do
  before(:each) do
    @columns = mock(:@columns)
    @columns.should_receive(:model).any_number_of_times.and_return(Gardener)
    @columns.should_receive(:table).any_number_of_times.and_return('gardeners')
  end
  
  it "should build correct SQL select clause" do
    @columns.should_receive(:index).any_number_of_times.and_return(nil)
    @columns.should_receive(:table_alias).with(:singularize).any_number_of_times.and_return('gardener')
    @columns.should_receive(:table_alias).with().any_number_of_times.and_return('gardeners')
    column = CommaHeaven::Sqler::Column.new(@columns, 1, 'name', nil)
    column.select.should == 'gardeners.name AS "gardener_name"'
  end

  it "should allow exclicit aliasing" do
    @columns.should_receive(:index).any_number_of_times.and_return(nil)
    @columns.should_receive(:table_alias).any_number_of_times.and_return('gardeners')
    column = CommaHeaven::Sqler::Column.new(@columns, 1, 'name', 'as')
    column.select.should == 'gardeners.name AS "as"'
  end
end
