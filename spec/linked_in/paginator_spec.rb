require 'spec_helper'

describe LinkedIn::Paginator do
  let(:client){ LinkedIn::Client.new('token', 'secret') }
  let(:path) { }
  let(:options){ }
  let(:paginator){ LinkedIn::Paginator.new client, "/people" }
  
  context "when there is only one page of results" do
    before do
      stub_get "/v1/people?start=0&count=25", "people.xml"
    end
    
    it "yields the page's response body" do
      paginator.each do |page|
        page.should == fixture_file("people.xml")
      end
    end
    
    it "yields the page only once" do
      yielded = 0
      paginator.each { |page| yielded += 1 }
      yielded.should == 1
    end
  end
  
  context "when there is more than one page of results" do
    before do
      stub_get "/v1/people?start=0&count=25", "people-page1.xml"
      stub_get "/v1/people?start=25&count=25", "people-page2.xml"
    end
    
    it "yields each page's response body" do
      pages_in_order = [ fixture_file("people-page1.xml"), fixture_file("people-page2.xml")]
      paginator.each_with_index do |page, i|
        page.should == pages_in_order[i]
      end
    end

    it "yields each page only once" do
      yielded = 0
      paginator.each { |page| yielded += 1 }
      yielded.should == 2
    end
    
  end

end