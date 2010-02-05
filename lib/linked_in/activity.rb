module LinkedIn
  class Activity
    include ROXML
    xml_convention {|val| val.gsub("_","-") }
    xml_reader :app_id
    xml_reader :body
  end
end