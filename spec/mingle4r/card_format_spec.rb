require File.dirname(__FILE__) + '/../spec_helper'

include Mingle4r

class DummyCard < ActiveResource::Base ; end
class CardType < ActiveResource::Base ; end

describe CardFormat do
  before(:all) do
    DummyCard.site = 'http://localhost'
    CardType.site = 'http://localhost'
  end
  
  before(:each) do
    @card_format = CardFormat.new
  end

  it "should be have the extension as 'xml'" do
    @card_format.extension.should == 'xml'
  end

  it "should have a mime type of application/xml" do
    @card_format.mime_type.should == 'application/xml'
  end

  context "decode" do
    it "should decode to right xml" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <card><name>Yet another bug</name>
        <card_type_name>Bug</card_type_name>
        <properties type="array">
          <property type_description="Card" hidden="false">
            <name>Defect Fix Completed in Iteration</name>
            <value type="integer">34</value>
          </property>
        </properties>
      </card>
XML
      @card_format.decode(xml).should == {"name"=>"Yet another bug", "card_type_name"=>"Bug",
        "properties"=>[{"name"=>"Defect Fix Completed in Iteration", "type_description"=>"Card", "value"=>34, "hidden"=>"false"}]}
    end
  end

  context "encode" do
    it "should be able to encode properly" do
      xml = '<?xml version="1.0" encoding="UTF-8"?>' + "\n" +
      "<dummy_card>\n" +
      "  <card_type>\n" +
      "  </card_type>\n" +
      "</dummy_card>\n"
      DummyCard.format = @card_format
      dummy_resource = DummyCard.new(:card_type => CardType.new)
      encoded = dummy_resource.encode(:root => 'dummy_card')
      encoded.should == xml
    end
    
    it "should convert tree relationship property appropriately" do
      card = DummyCard.new(:number => 116,
      :properties => [{ :type_description => 'Any card used in tree',
        :hidden   => 'false', :name => 'Feature',
        :value    => {:url => "http://localhost:8080/api/v2/projects/agile_hybrid_project/cards/117.xml",
        :number   => 117}}])
      expected_xml = load_fixture('card_with_tree_relationship_property_final.xml')
      actual_xml = @card_format.encode(card.attributes, :root => 'card')
      actual_xml.should == expected_xml
    end
    
    it "should convert card relationship property appropriately" do
      card = DummyCard.new(:name => 'Contact API',
      :properties => [{ :type_description => 'Card',
        :hidden   => 'false', :name => 'Feature',
        :value    => {:url => "http://localhost:8080/api/v2/projects/agile_hybrid_project/cards/37.xml",
        :number   => 37}}])
      expected_xml = load_fixture('card_with_card_relationship_property_final.xml')
      actual_xml = @card_format.encode(card.attributes, :root => 'card')
      actual_xml.should == expected_xml
    end
  end
end