require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Columns" do
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
  
  # Examples of SQL to be produced: 
  #
  # SELECT 
  # 	c.id,
  # 	p0.`address`,
  # 	p1.`address`,
  # 	p2.`address`,
  # 	r0.id,
  # 	r0_c.name,
  # 	r1.id,
  # 	r1_c.name,
  # 	r2.id,
  # 	r2_c.name,
  # 	r3.id,
  # 	r3_c.name
  #
  # FROM `contacts` c
  # 
  # LEFT JOIN `registrations` AS r0
  # 	ON c.id = r0.`contact_id` 
  # 	AND r0.id = (SELECT id FROM `registrations` WHERE `contact_id` = c.id ORDER BY `created_at` LIMIT 0, 1)
  # LEFT JOIN `registrations` AS r1
  # 	ON c.id = r1.`contact_id` 
  # 	AND r1.id = (SELECT id FROM `registrations` WHERE `contact_id` = c.id ORDER BY `created_at` LIMIT 1, 1)
  # LEFT JOIN `registrations` AS r2
  # 	ON c.id = r2.`contact_id` 
  # 	AND r2.id = (SELECT id FROM `registrations` WHERE `contact_id` = c.id ORDER BY `created_at` LIMIT 2, 1)
  # LEFT JOIN `registrations` AS r3
  # 	ON c.id = r3.`contact_id` 
  # 	AND r3.id = (SELECT id FROM `registrations` WHERE `contact_id` = c.id ORDER BY `created_at` LIMIT 3, 1)
  # 
  # LEFT JOIN `courses` AS r0_c
  # 	ON r0_c.id = r0.`course_id`
  # LEFT JOIN `courses` AS r1_c
  # 	ON r1_c.id = r1.`course_id`
  # LEFT JOIN `courses` AS r2_c
  # 	ON r2_c.id = r2.`course_id`
  # LEFT JOIN `courses` AS r3_c
  # 	ON r3_c.id = r3.`course_id`
  # 
  # LEFT JOIN `postal_addresses` AS p0
  # 	ON c.id = p0.`contact_id` 
  # 	AND p0.id = (SELECT id FROM `postal_addresses` WHERE `contact_id` = c.id LIMIT 0, 1)
  # LEFT JOIN `postal_addresses` AS p1
  # 	ON c.id = p1.`contact_id` 
  # 	AND p1.id = (SELECT id FROM `postal_addresses` WHERE `contact_id` = c.id LIMIT 1, 1)
  # LEFT JOIN `postal_addresses` AS p2
  # 	ON c.id = p2.`contact_id` 
  # 	AND p2.id = (SELECT id FROM `postal_addresses` WHERE `contact_id` = c.id LIMIT 2, 1)
  # 
  #
  #
  # SELECT p.id, f.id, f.`followup_date`
  # FROM `adiuvo_patients` p
  # LEFT JOIN `adiuvo_followup` f ON p.id = f.`patient_id`;
  #
  #
  # 
  # SELECT p.id, f0.id, f0.`followup_date`
  # FROM `adiuvo_patients` p
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f0 
  #   ON p.id = f0.`patient_id` 
  #   AND f0.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 0, 1);
  #
  #
  # 
  # SELECT p.id, f0.id, f0.`followup_date`, f1.id, f1.`followup_date`
  # FROM `adiuvo_patients` p
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f0 
  #   ON p.id = f0.`patient_id` 
  #   AND f0.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 0, 1)
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f1
  #   ON p.id = f1.`patient_id` 
  #   AND f1.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 1, 1);
  # 
  #
  #
  # SELECT p.id, f0.id, f0.`followup_date`, f1.id, f1.`followup_date`, f2.id, f2.`followup_date`
  # FROM `adiuvo_patients` p
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f0 
  #   ON p.id = f0.`patient_id` 
  #   AND f0.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 0, 1)
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f1
  #   ON p.id = f1.`patient_id` 
  #   AND f1.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 1, 1)
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f2
  #   ON p.id = f2.`patient_id` 
  #   AND f2.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 2, 1);
  # 
  #
  #
  # SELECT 
  #   CONCAT(
  #     IFNULL(p.id, '""'), ';', 
  #     IFNULL(f0.id, '""'), ';', 
  #     IFNULL(f0.`followup_date`, '""'), ';', 
  #     IFNULL(f1.id, '""'), ';', 
  #     IFNULL(f1.`followup_date`, '""'), ';', 
  #     IFNULL(f2.id, '""'), ';', 
  #     IFNULL(f2.`followup_date`, '""')
  #   )
  # FROM `adiuvo_patients` p
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f0 
  #   ON p.id = f0.`patient_id` 
  #   AND f0.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 0, 1)
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f1
  #   ON p.id = f1.`patient_id` 
  #   AND f1.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 1, 1)
  # LEFT JOIN (SELECT * FROM `adiuvo_followup`) AS f2
  #   ON p.id = f2.`patient_id` 
  #   AND f2.id = (SELECT id FROM `adiuvo_followup` WHERE `patient_id` = p.id LIMIT 2, 1);

  
  it "should build correct SQL select clause exporting simple fields" do
    columns = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}})
    columns.select.should == 'trees.name AS "tree_name", trees.age AS "tree_age"'
  end
  
  it "should build correct SQL select clause exporting simple fields, including only wanted fields" do
    columns = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '0', :as => ''}}})
    columns.select.should == 'trees.name AS "tree_name"'
  end
   
  it "should build correct SQL select and joins clauses exporting has many association" do
    columns = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}, :leafs => {2 => {:export => {:position => {4 => {:include => '1', :as => ''}}}, :limit => '3'}}})
    columns.select.should == 'trees.name AS "tree_name", trees.age AS "tree_age", leafs_0.position AS "leaf_0_position", leafs_1.position AS "leaf_1_position", leafs_2.position AS "leaf_2_position"'
    columns.joins.should  =~ /LEFT JOIN/
  end
  
  it "should build correct SQL select and joins clauses exporting belongs to association" do
    columns = CommaHeaven::Sqler::Columns.new(Tree, {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}, :gardener => {2 => {:export => {:surname => {4 => {:include => '1', :as => ''}}}}}})
    columns.select.should == 'trees.name AS "tree_name", trees.age AS "tree_age", gardeners.surname AS "gardener_surname"'
    columns.joins.should  =~ /\sgardeners\s/
    columns.joins.should  =~ /LEFT JOIN/
  end
  
  it "should build corrent SQL select and joins clauses for deeper associations" do
    columns = CommaHeaven::Sqler::Columns.new(Gardener, {:name => {0 => {:include => '1', :as => ''}}, :trees => {1 => {:export => {:name => {0 => {:include => '1', :as => ''}}, :age => {1 => {:include => '1', :as => ''}}, :gardener => {2 => {:export => {:surname => {4 => {:include => '1', :as => ''}}}}}}, :limit => 3}}})
    columns.select.should == 'gardeners.name AS "gardener_name", trees_0.name AS "tree_0_name", trees_0.age AS "tree_0_age", trees_0_gardeners.surname AS "tree_0_gardener_surname", trees_1.name AS "tree_1_name", trees_1.age AS "tree_1_age", trees_1_gardeners.surname AS "tree_1_gardener_surname", trees_2.name AS "tree_2_name", trees_2.age AS "tree_2_age", trees_2_gardeners.surname AS "tree_2_gardener_surname"'
    columns.joins.should  =~ /LEFT JOIN/
    columns.joins.should  =~ /trees/
    columns.joins.should  =~ /gardeners/
  end

  it "should build corrent SQL select and joins clauses for deeper and deeper associations" do
    export = {
      :name       => {0 => {:include => '1', :as => ''}}, 
      :trees      => {1 => {:export => {
        :name       => {2 => {:include => '1', :as => ''}}, 
        :age        => {3 => {:include => '1', :as => ''}}, 
        :gardener   => {4 => {:export => {
          :surname    => {5 => {:include => '1', :as => ''}}}}},
        :leafs      => {6 => {:export => {
          :position   => {7 => {:include => '1', :as => ''}}}, :limit => 2}}}, :limit => 3}}}
          
    columns = CommaHeaven::Sqler::Columns.new(Gardener, export)
  
    # puts "\n\n\n#{columns.joins}\n\n\n"
    # puts Gardener.scoped(:joins => columns.joins).first.inspect
    # puts Gardener.scoped(:joins => columns.joins, :select => columns.select).first.instance_variable_get(:"@attributes").inspect
    # puts Gardener.scoped(:joins => columns.joins, :select => columns.select).all.to_yaml
  
    columns.joins.should  =~ /LEFT JOIN/
    columns.joins.should  =~ /trees/
    columns.joins.should  =~ /gardeners/
    columns.joins.should  =~ /leafs/
    columns.select.should == 'gardeners.name AS "gardener_name", trees_0.name AS "tree_0_name", trees_0.age AS "tree_0_age", trees_0_gardeners.surname AS "tree_0_gardener_surname", trees_0_leafs_0.position AS "tree_0_leaf_0_position", trees_0_leafs_1.position AS "tree_0_leaf_1_position", trees_1.name AS "tree_1_name", trees_1.age AS "tree_1_age", trees_1_gardeners.surname AS "tree_1_gardener_surname", trees_1_leafs_0.position AS "tree_1_leaf_0_position", trees_1_leafs_1.position AS "tree_1_leaf_1_position", trees_2.name AS "tree_2_name", trees_2.age AS "tree_2_age", trees_2_gardeners.surname AS "tree_2_gardener_surname", trees_2_leafs_0.position AS "tree_2_leaf_0_position", trees_2_leafs_1.position AS "tree_2_leaf_1_position"'
    
    Gardener.scoped(:joins => columns.joins).count.should == 2
    Gardener.scoped(:joins => columns.joins, :select => columns.select).first.attributes.to_a.length.should == 16
  end
end
