check_blog_links_steps_failed=0
require './spec_helper'

twitter_url = 'https://www.twitter.com/atlantbh'
facebook_url = 'https://www.facebook.com/atlantbh'
linkedin_url = 'https://www.linkedin.com/company/1485526'
youtube_url = 'https://www.youtube.com/channel/UCM5ik6tZYgGU4MH6CvYFHxQ'
github_url = 'https://github.com/ATLANTBH'
instagram_url = 'https://www.instagram.com/atlantbh/'

chat_msg = "Welcome there! Questions? We're here, send us a message."

describe "Check blog links" do
  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if check_blog_links_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          check_blog_links_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:blog) { @homepage.get_main.get_blog }
  let(:single_blog) { @homepage.get_main.get_blog.get_single_blog }
  let(:blog_group) { @homepage.get_main.get_blog.get_blog_group }
  let(:chat) { @homepage.get_main.get_chat }

  context "Click on navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on blog in navigation" do
    it "opens blog page" do
      main.close_slaask_popup_if_present
      main.click_on_navigation_blog
    end
  end

  context "Check if chat widget is functional" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Click on first blog" do
    it "opens blog" do
      expect(blog.click_on_first_blog).to eq(true)
      main.click_back
    end
  end

  context "Check blog data on second blog" do
    it "verifies that data, name and blog type exist" do
      data = blog.check_blog_data(2)
      data_empty = false
      data.each do |x|
        data_empty = true if x == ''
      end
      expect(data_empty).to eq(false)
    end
  end

  context "Click on second blog" do
    it "opens blog" do
      chat.click_chat_button
      chat.close_chat
      expect(blog.click_on_specific_blog(2)).to eq(true)
    end
  end

  context "Check if chat widget is functional on single blog page" do
    it "Chat widget displayed" do
      chat.click_chat_button
      expect(chat.check_if_widget_is_visible?).to be true
      chat.close_chat
    end
  end

  context "Check social media share exists" do
    it "verifies social media links exist" do
      single_blog.check_social_media_share_exists?
    end
  end

  context "Check that Disquss form is loaded for comments" do
    it "verifies that Discuss form exists" do
      single_blog.check_disquss_form_is_loaded?
    end
  end

  context "Click on blog type" do
    it "opens specific blog type" do
      expect(single_blog.click_on_blog_type).to eq(true)
    end
  end

  context "Check blog data on first blog" do
    it "verifies that data, name and blog type exist" do
      data = single_blog.check_blog_data(1)
      data_empty = false
      data.each do |x|
        data_empty = true if x == ''
      end
      expect(data_empty).to eq(false)
    end
  end

  context "Check that links to social networks are valid and exist" do
    it "verifies that social network links are valid" do
      main.click_back
      main.click_back
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