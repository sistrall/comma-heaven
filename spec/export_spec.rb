require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Export" do
  before(:each) do
    alice = Gardener.create(:name => 'Alice')
    bob   = Gardener.create(:name => 'Bob')
    
    olmo = Tree.create(:name => 'Olmo', :age => 100, :gardener => alice)
    olmo.leafs.create(:position => 'top')
    olmo.leafs.create(:position => 'middle')
    olmo.leafs.create(:position => 'bottom')

    ulivo = Tree.create(:name => 'Ulivo', :age => 150, :gardener => bob)
    ulivo.leafs.create(:position => '0', :height_from_ground => 1)
    ulivo.leafs.create(:position => '5', :height_from_ground => 2)

    @params = 
      { 'export' => { "id" => {"0" => {"as" => '', 'include' => '0'} },
                      "name" => {"1" => {"as" => "", "include" => "1"} }, 
                      "leafs" => {"2" => {"export" => { "position" => {"3" => {"as" => "", "include" => '1'} },
                                                          "height_from_ground" => {"4" => {'as' => '', :include => '1'} } } } } } }
  end
  
  it 'should make available columns available as methods' do
    Tree.export(@params).leafs.should be_instance_of(CommaHeaven::Export)
    Tree.export(@params).leafs.id.should be_instance_of OpenStruct
    Tree.export(@params).leafs.position.should == OpenStruct.new("as" => "", "include" => "1")
  end
  
  it 'should make associations available as methods' do
    Tree.export.should be_instance_of(CommaHeaven::Export)
    Tree.export.name.should == OpenStruct.new

    Tree.export(@params).should be_instance_of(CommaHeaven::Export)
    Tree.export(@params).id.should be_instance_of OpenStruct
    Tree.export(@params).name.should == OpenStruct.new("as" => "", "include" => "1")
  end
  
  it "should export to CSV" do
    Tree.export(:export => {:name => {0 => {}}, :age => {1 => {}}}).save.should ==
      Tree.to_comma_heaven(:export => {:name => {0 => {}}, :age => {1 => {}}}).to_csv
  end

  it "should export scoped model" do
    Tree.scoped(:conditions => {:name => 'Ulivo'}).export(@params).save.should ==
      Tree.scoped(:conditions => {:name => 'Ulivo'}).to_comma_heaven(@params).to_csv
  end

  it "should export to CSV using customized options made available through FasterCSV" do
    Tree.export(:export => {:name => {0 => {}}, :age => {1 => {}}}, :col_sep => ";", :force_quotes => true).save.should ==
      Tree.to_comma_heaven(:export => {:name => {0 => {}}, :age => {1 => {}}}).to_csv(:col_sep => ";", :force_quotes => true)

    Tree.export(:export => {:name => {0 => {}}, :age => {1 => {}}}, 'col_sep' => ";", 'force_quotes' => true).save.should ==
      Tree.to_comma_heaven(:export => {:name => {0 => {}}, :age => {1 => {}}}).to_csv(:col_sep => ";", :force_quotes => true)
  end
  
  it "should respect scopes" do
    Tree.that_begins_with_o.export(:export => {:name => {0 => {}}, :age => {1 => {}}}).save.should ==
      Tree.that_begins_with_o.to_comma_heaven(:export => {:name => {0 => {}}, :age => {1 => {}}}).to_csv
  end
  
  it "should initialize options to an empty hash" do
    CommaHeaven::Export.new(Tree, Tree.scoped({})).options.should == Hash.new
  end

  it "should correctly initialize options" do
    CommaHeaven::Export.new(Tree, Tree.scoped({}), :col_sep => ';').options.should == {:col_sep => ';'}
  end
end

