check_home_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

describe "Check home links" do

  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_home_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_home_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:contact) { @homepage.get_main.get_contact }
  let(:blog) { @homepage.get_main.get_blog }
  let(:chat) { @homepage.get_main.get_chat }

  context "Click on navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on home in navigation" do
    it "opens home page" do
      main.close_slaask_popup_if_present
      home_header = main.click_on_navigation_home
      expect(home_header).to match(/Software Development Company/i)
    end
  end

  context "Check if chat widget is functional" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Click on problem meets solution" do
    it "opens expertise page" do
      message = main.click_on_expertise
      expect(message).to match(/Expertise/i)
      main.click_back
    end
  end

  context "Click on first in the world to extract hours of operation" do
    it "opens hop page" do
      message = main.click_on_hop
      expect(message).to match("First In The World To Extract Hours Of Operation (HOP)")
      main.click_back
    end
  end

  context "Click on experience life on top" do
    it "opens life page" do
      message = main.click_on_life
      expect(message).to match(/Careers @ Atlantbh/i)
      main.click_back
    end
  end

  context "Check referalls exist" do
    it "verified that referrals exist" do
      main.check_referrals_exist?
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
