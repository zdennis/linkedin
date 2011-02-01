module LinkedIn
  class People < Array
    def self.from_xml(doc)
      new(Nokogiri::XML(doc))
    end

    def initialize(doc=nil)
      add_profiles_from_xml doc if doc
    end

    def add_profiles_from_xml(doc)
      doc = Nokogiri::XML(doc) if doc.is_a?(String)
      doc.xpath('//people').children.each do |profile|
        self << Profile.new(Nokogiri::XML(profile.to_xml)) unless profile.blank?
      end
    end

  end
end
