check_about_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

email = "automation@atlantbh.com"

describe "Check about links" do

  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_about_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_about_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:about) { @homepage.get_main.get_about }
  let(:chat) { @homepage.get_main.get_chat }
  let(:contact) { @homepage.get_main.get_contact }

  context "Click on mobile navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on about in navigation" do
    it "opens about page" do
      main.close_slaask_popup_if_present
      about_header = main.click_on_navigation_about
      expect(about_header).to match(/software and product development/i)
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
      intro_title = about.check_intro_exists?
      expect(intro_title).to match(/successfully delivering software systems … it’s kind of our thing/i)
    end
  end

  context "Click first case study link" do
    it "Expertise page is opened" do
      case_study_header = about.click_first_casestudy
      expect(case_study_header).to match(/expertise/i)
    end

    it "goes back" do
      main.click_back
    end
  end

  context "Click second case study link" do
    it "Careers @ Atlantbh page is opened" do
      case_study_header = about.click_second_casestudy
      expect(case_study_header).to match(/careers @ atlantbh/i)
    end

    it "goes back" do
      main.click_back
    end
  end

  context "Check that subscribe section is present" do
    it "verifies that subscribe section is present" do
        about.check_subscribe_exists?
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
