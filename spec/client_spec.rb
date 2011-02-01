require 'spec_helper'

describe LinkedIn::Client do
  context "when hitting the LinkedIn API" do
    before do
      @linkedin = LinkedIn::Client.new('token', 'secret')
      consumer = OAuth::Consumer.new('token', 'secret', {:site => 'https://api.linkedin.com'})
      @linkedin.stub(:consumer).and_return(consumer)

      @linkedin.authorize_from_access('atoken', 'asecret')
    end

    it "retrieve a profile for the authenticated user" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p.first_name.should == 'Wynn'
      p.last_name.should  == 'Netherland'
    end
    
    it "retrieve location information" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p.location.name.should    == 'Dallas/Fort Worth Area'
      p.location.country.should == 'us'
    end
    
    it "retrieve positions from a profile" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p.positions.size.should == 4
      p.positions.first.company.name.should == 'Orrka'
      p.positions.first.is_current.should   == 'true'
      
      hp = p.positions[2]
      hp.title.should       == 'Solution Architect'
      hp.id.should          == '4891362'
      hp.start_month.should == 10
      hp.start_year.should  == 2004
      hp.end_month.should   == 6
      hp.end_year.should    == 2007
      hp.is_current.should  == 'false'
    end

    it "retrieve education information from a profile" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      education = p.education.first
      education.start_month.should == 8
      education.start_year.should  == 1994
      education.end_month.should   == 5
      education.end_year.should    == 1998
    end

    it "retrieve information about a profiles connections" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p.connections.size.should == 146
      p.connections.first.first_name.should == "Ali"
    end
    
    it "retrieve a profiles member_url_resources" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p.member_url_resources.size.should == 2
      p.member_url_resources.first.url.should  == 'http://orrka.com'
      p.member_url_resources.first.name.should == 'My Company'
    end
    
    it "retrieve a profiles connections api_standard_profile_request" do
      stub_get("/v1/people/~", "profile_full.xml")
      p = @linkedin.profile
      p1 = p.connections.first
      p1.api_standard_profile_request.url.should == 'http://api.linkedin.com/v1/people/3YNlBdusZ5:full'
      p1.api_standard_profile_request.headers[:name].should  == 'x-li-auth-token'
      p1.api_standard_profile_request.headers[:value].should == 'name:lui9'
    end

    it "retrieve a profile for a member by id" do
      stub_get("/v1/people/id=gNma67_AdI", "profile.xml")
      p = @linkedin.profile(:id => "gNma67_AdI")
      p.first_name.should == 'Wynn'
    end

    it "retrieve a site_standard_profile_request" do
      stub_get("/v1/people/~", "profile.xml")
      p = @linkedin.profile
      p.site_standard_profile_request.should == "http://www.linkedin.com/profile?viewProfile=&key=3559698&authToken=yib-&authType=name"
    end

    it "retrieve a profile for a member by url" do
      stub_get("/v1/people/url=http%3A%2F%2Fwww.linkedin.com%2Fin%2Fnetherland", "profile.xml")
      p = @linkedin.profile(:url => "http://www.linkedin.com/in/netherland")
      p.last_name.should == 'Netherland'
    end

    it "accept field selectors when retrieving a profile" do
      stub_get("/v1/people/~:(first-name,last-name)", "profile.xml")
      p = @linkedin.profile(:fields => [:first_name, :last_name])
      p.first_name.should == 'Wynn'
      p.last_name.should == 'Netherland'
    end

    it "retrieve connections for the authenticated user" do
      stub_get("/v1/people/~/connections", "connections.xml")
      cons = @linkedin.connections
      cons.size.should == 146
      cons.last.last_name.should == 'Yuchnewicz'
    end
    
    describe "#people_search" do
      before do
        # page1 includes 2 results
        stub_get "/v1/people-search?first-name=Joe&start=0&count=25", "people-page1.xml"
        # page2 includes 2 results
        stub_get "/v1/people-search?first-name=Joe&start=25&count=25", "people-page2.xml"
      end
      
      it "finds and returns all people found, including paginating results" do
        people = @linkedin.people_search(:first_name => "Joe")
        people.count.should == 4
      end
    end

    it "perform a search by keyword" do
      stub_get("/v1/people?start=0&count=25&keywords=github", "search.xml")
      people = @linkedin.search(:keywords => 'github')
      people.first.first_name.should == 'Zach'
      people.first.last_name.should  == 'Inglis'
    end

    it "perform a search by multiple keywords" do
      $c = true
      stub_get("/v1/people?start=0&count=25&keywords=ruby+rails", "search.xml")
      people = @linkedin.search(:keywords => ["ruby", "rails"])
      people.first.first_name.should == 'Zach'
      people.first.last_name.should  == 'Inglis'
    end

    it "perform a search by name" do
      stub_get("/v1/people?start=0&count=25&name=Zach+Inglis", "search.xml")
      people = @linkedin.search(:name => "Zach Inglis")
      people.first.first_name.should == 'Zach'
      people.first.last_name.should  == 'Inglis'
    end

    it "update a user's current status" do
      stub_put("/v1/people/~/current-status", "blank.xml")
      @linkedin.update_status("Testing out the LinkedIn API")
    end

    it "clear a user's current status" do
      stub_delete("/v1/people/~/current-status", "blank.xml")
      @linkedin.clear_status
    end

    it "retrieve the authenticated user's current status" do
      stub_get("/v1/people/~/current-status", "status.xml")
      @linkedin.current_status.should == "New blog post: What makes a good API wrapper? http://wynnnetherland.com/2009/11/what-makes-a-good-api-wrapper/"
    end

    it "retrieve status updates for the authenticated user's network" do
      stub_get("/v1/people/~/network?type=STAT", "network_statuses.xml")
      stats = @linkedin.network_statuses
      stats.updates.first.timestamp.should == 1259179809524
      stats.updates.first.profile.id.should == "19408512"
      stats.updates.first.profile.first_name.should == 'Vahid'
      stats.updates.first.profile.connections.first.id.should == "28072758"
      stats.updates.first.profile.connections.first.last_name.should == 'Varone'
    end

    it "retrieve network updates" do
      stub_get("/v1/people/~/network?type=PICT", "picture_updates.xml")
      stats = @linkedin.network_updates(:type => "PICT")
      stats.updates.size.should == 4
      stats.updates.last.profile.headline.should == "Creative Director for Intridea"
    end

    it "send a message to recipients" do
      stub_post("/v1/people/~/mailbox", "mailbox_items.xml")
      recipients = ["/people/~", "/people/abcdefg"]
      subject    = "Congratulations on your new position."
      body       = "You're certainly the best person for the job!"

      @linkedin.send_message(subject, body, recipients) == "200"
    end
  end
end
