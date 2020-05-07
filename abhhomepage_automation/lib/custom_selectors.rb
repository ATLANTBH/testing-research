Capybara.add_selector(:menu_area) do
  xpath { "//div[@id=\"header-outer\"]/header/div/div" }
end

Capybara.add_selector(:mobile_menu_area) do
  xpath { "//div[@class=\"off-canvas-menu-container mobile-only\"]/div/ul[@class=\"menu menuopen\"]" }
end

Capybara.add_selector(:contact_form) do
  xpath { "//div[@class=\"wpb_wrapper\"]/div[@id=\"wpcf7-f5-p25-o1\"]/form" }
end

Capybara.add_selector(:subscribe_contact_form) do
  xpath { "//div[@class=\"wpb_wrapper\"]/div[@class=\"wpcf7\"]/form" }
end

Capybara.add_selector(:posts_container) do
  xpath { "//div[@class=\"posts-container meta-moved\"]" }
end

Capybara.add_selector(:first_blog) do
  xpath { "//article[1]/div[@class=\"inner-wrap\"]/div[@class=\"post-content\"]" }
end

Capybara.add_selector(:specific_blog) do
  xpath { |index| "//article[#{index}]/div[@class=\"inner-wrap\"]/div[@class=\"post-content\"]" }
end

Capybara.add_selector(:specific_blog_safari) do
  xpath { |index| "//article[#{index}]/div[@class=\"inner-wrap\"]/div[@class=\"post-content\"]/a" }
end

Capybara.add_selector(:specific_blog_area) do
  xpath { "//div[@class=\"row heading-title hentry\"]" }
end

Capybara.add_selector(:specific_blog_share_area) do
  xpath { "//div[@class=\"bottom-meta\"]" }
end

Capybara.add_selector(:clients_and_stories_middle_area) do
  xpath { "//div[@class=\"col span_12 dark left\"]/div[@class=\"vc_col-sm-12 wpb_column column_container vc_column_container col no-extra-padding instance-3\"]" }
end

Capybara.add_selector(:main_middle_area) do
  xpath { "//div[@class = \"col span_12 custom left\"]/div[@class = \"vc_col-sm-12 remove-margin wpb_column column_container vc_column_container col no-extra-padding instance-3\"]" }
end

Capybara.add_selector(:main_referrals_area) do
  xpath { "//div[@class = \"col span_12 custom left\"]/div[@class = \"vc_col-sm-12 wpb_column column_container vc_column_container col no-extra-padding instance-12\"]" }
end

Capybara.add_selector(:main_footer_area) do
  xpath { "//div[@id=\"footer-outer\"]/div[@id=\"copyright\"]/div[@class=\"container\"]" }
end

Capybara.add_selector(:slaask_popup_area) do
  xpath { "//div[@id=\"slaask-alert\"]" }
end