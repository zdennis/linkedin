module LinkedIn
  class Recommendation
    include ROXML
    xml_convention {|val| val.gsub("_","-") }
    xml_reader :id
    xml_reader :recommendation_type
    xml_reader :recommendation_snippet
  end
end