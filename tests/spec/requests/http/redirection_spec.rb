require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

context Restfulie::Client::HTTP do

  context "redirection" do
    
    let(:resp) {
      Restfulie.at("http://localhost:4567/test_redirection").follow.get!
    }
    
    it "should follow redirection" do
      resp.response.request.path.should == "/redirected"
    end
    
    it "should set the body as 'OK'" do
      resp.body.should == "OK"
    end
    
  end

end

