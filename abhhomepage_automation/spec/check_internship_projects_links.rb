check_internship_projects_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

describe "Check internship projects links" do

  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_internship_projects_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_internship_projects_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:internship) { @homepage.get_main.get_internship }
  let(:internship_projects) { @homepage.get_main.get_internship_projects }
  let(:chat) { @homepage.get_main.get_chat }

  context "Click on navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on internship in navigation" do
    it "opens internship page" do
      main.close_slaask_popup_if_present
      internship_header = main.click_on_navigation_internship
      expect(internship_header).to match(/#ABHInternship/i)
    end
  end

  context "Check if chat widget is functional" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Click on internship projects" do
    it "opens internship projects" do
      internship_projects_header = internship.click_internship_projects
      expect(internship_projects_header).to match(/Pick A Project/i)
    end
  end

  context "Check if chat widget is functional on internship projects" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Check all sections are present" do
    it "verifies all sections are present" do
      expect(internship_projects.check_sections_present).to eq true
      expect(internship_projects.check_remaining_sections).to eq true
    end

    it "goes back on internship page" do
      main.click_back
    end
  end

  context "Click on internship stories" do
    it "opens internship stories" do
      internship_stories_header = internship.click_internship_stories
      expect(internship_stories_header).to match(/Intern Q&A/i)
    end

    it "goes back on internship page" do
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