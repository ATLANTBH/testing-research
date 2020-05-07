check_expertise_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

email = "automation@atlantbh.com"

describe "Check expertise links" do
  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_expertise_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_expertise_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end
  let(:main) { @homepage.get_main }
  let(:expertise) { @homepage.get_main.get_expertise }
  let(:chat) { @homepage.get_main.get_chat }
  let(:contact) { @homepage.get_main.get_contact }

  context "Click on navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on expertise in navigation" do
    it "opens expertise page" do
      main.close_slaask_popup_if_present
      expertise_header = main.click_on_navigation_expertise
      expect(expertise_header).to match(/expertise/i)
    end
  end

  context "Check if chat widget is functional" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Check all sections are present" do
    it "verifies all sections are present" do
      expect(expertise.check_sections_present).to eq true
    end
  end

  context "Check that subscribe section is present" do
    it "verifies that subscribe section is present" do
        expertise.check_subscribe_exists?
    end
  end

  context "Check that user can subscribe" do
    it "fills in email" do 
      sleep 2
      contact.fill_in_email_subscribe(email)
    end

    it "clicks on send button" do
      contact.click_on_subscribe_button
    end

    it "sends message successfully" do
      send_message = contact.get_subscribe_contact_message_successfull
      expect(send_message).to eq("Thank you for your message. It has been sent.")
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
