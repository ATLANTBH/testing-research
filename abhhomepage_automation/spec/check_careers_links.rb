check_careers_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

describe "Check careers links" do

  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_careers_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_careers_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:lifeat) { @homepage.get_main.get_lifeat }
  let(:chat) { @homepage.get_main.get_chat }

  context "Click on mobile navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on careers in navigation" do
    it "opens careers page" do
      main.close_slaask_popup_if_present
      lifeat_header = main.click_on_navigation_lifeat
      expect(lifeat_header).to match(/careers @ atlantbh/i)
    end
  end

  context "Check if chat widget is functional" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Check intro div exists" do
    it "verified that intro exists" do
      intro_title = lifeat.check_intro_exists?
      expect(intro_title).to match(/the air is better up here/i)
    end
  end

  context "Click first case study link" do
    it "Blog page is opened" do
      case_study_header = lifeat.click_first_casestudy
      if Capybara.current_driver == :safari && @homepage.platform != 'mobile_ios'
        expect(case_study_header).to match(/blog/i)
      else
        expect(case_study_header).to match(/blog/i)
      end
    end

    it "goes back" do
      main.click_back
    end
  end

  context "Click second case study link" do
    it "Atlanters In Focus page is opened" do
      case_study_header = lifeat.click_second_casestudy
      if Capybara.current_driver == :safari && @homepage.platform != 'mobile_ios'
        expect(case_study_header).to match(/atlanters in focus/i)
      else
        expect(case_study_header).to match(/atlanters in focus/i)
      end
    end

    it "goes back" do
      main.click_back
    end
  end

  context "Check that subscribe section is present" do
    it "verifies that subscribe section is present" do
        lifeat.check_joinnow_exists?
    end
  end

  context "Check that user can join" do
    it "verifies that user can open workable website" do
      sleep 2
      if Capybara.current_driver == :safari && @homepage.platform != 'mobile_ios'
        workable_url = lifeat.check_joinnow_works?
        expect(workable_url).to include("apply.workable.com/atlantbh")
      else
        workable_url = lifeat.check_joinnow_works?
        expect(workable_url).to include("apply.workable.com/atlantbh")
      end
    end

    it "goes back" do
      main.click_back
    end
  end

  context "Check that links to social networks are valid and exist" do
    it "verifies that social network links are valid" do
      main.check_social_network_link_valid(twitter_url, 1)
      main.check_social_network_link_valid(facebook_url, 2)
      main.check_social_network_link_valid(linkedin_url, 3)
      main.check_social_network_link_valid(youtube_url, 4)
      main.check_social_network_link_valid(github_url, 5)
      main.check_social_network_link_valid(instagram_url, 6)
    end
  end

  after(:all) do
    @homepage.close_browser
  end
end
