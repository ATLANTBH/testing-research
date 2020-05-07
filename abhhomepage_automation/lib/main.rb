require './lib/homepage'

class Main < HomePage
  def click_on_navigation
    if @platform =~ /mobile/ and @orientation == 'portrait'
      @session.find(:css, "a[href='#sidewidgetarea']").click
      @session.find(:css, "div.off-canvas-menu-container.mobile-only")
    end
  end

  def click_on_navigation_contact
    if @platform =~ /mobile/ and @orientation == 'portrait'
      @session.within(:mobile_menu_area) do
        @session.find_link('Contact').click
        @session.driver.browser.find_element(:css,"div.wpb_wrapper > h3").text
      end
    else
      @session.within(:menu_area) do
        @session.find_link('Contact').click
        @session.driver.browser.find_element(:css,"div.wpb_wrapper > h3").text
      end
    end
  end

  def close_slaask_popup_if_present
    i = 1
    count = 5
    interval = 1
# Commented out since it can cause an issue with losing selenium webdriver session (Selenium::WebDriver::Error::ServerError)
# Not needed now since there is no active popup area
=begin
    begin
      i = i+1
      while i < count
        @session.within(:slaask_popup_area, wait: 1) do
          @session.click_link("No, thanks")
        end
        break
      end
    rescue Capybara::ElementNotFound => e
      puts "Popup not found...Retrying #{i} time"
      sleep interval
      retry
    end
=end
  end

  def click_on_navigation_home
    @session.within(:menu_area) do
      @session.find_link('Home').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_about
    @session.within(:menu_area) do
      @session.find_link('About').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_work
    @session.within(:menu_area) do
      @session.find_link('Case Studies').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_expertise
    @session.within(:menu_area) do
      @session.find_link('Expertise').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_lifeat
    @session.within(:menu_area) do
      @session.find_link('Careers').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_careers
    @session.within(:menu_area) do
      @session.find_link('Careers').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_internship
    @session.within(:menu_area) do
      @session.find_link('Students').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_navigation_blog
    @session.within(:menu_area) do
      @session.find_link('Blog').click
      @session.driver.browser.find_element(:css,"div.posts-container > article:nth-of-type(1)")
    end
  end

  def click_on_navigation_clients_and_stories
    @session.within(:menu_area) do
      @session.find_link('Clients & Stories').click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_clients_and_stories
    @session.within(:main_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/clients\"] > picture > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/clients\"] > picture > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_success_story_staffyourself
    @session.within(:clients_and_stories_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_staffyourself/\"] > picture > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css, "div.wpb_wrapper > div > div > a[href=\"/success_story_staffyourself/\"] > picture > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_success_story_startup
    @session.within(:clients_and_stories_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_startup\"] > picture > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_startup\"] > picture > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_success_story_hundred_days
    @session.within(:clients_and_stories_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_hundred_days/\"] > picture > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_hundred_days/\"] > picture > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_success_story_mobile_app
    @session.within(:clients_and_stories_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_mobile_app/\"] > picture > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/success_story_mobile_app/\"] > picture > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_expertise
    @session.within(:main_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/expertise\"] > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/expertise\"] > img")
      element.click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_automating_mobile_build_distribution
    @session.within(:main_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/software-development/automating_mobile_build_distribution_part1_android/\"] > img")
      @session.driver.browser.execute_script("arguments[0].scrollIntoView()", element)
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/software-development/automating_mobile_build_distribution_part1_android/\"] > img")
      element.click
      @session.driver.browser.find_element(:css, "div.col.span_12.section-title.blog-title > h1").text
    end
  end

  def click_on_hop
    @session.within(:main_middle_area) do
      element = @session.driver.browser.find_element(:css,"div.wpb_wrapper > div > div > a[href=\"/news/hop/\"] > img")
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/news/hop/\"] > img")
      element.click
      @session.driver.browser.find_element(:css, "div.col.span_12.section-title.blog-title > h1").text
    end
  end

  def click_on_life
    @session.within(:main_middle_area) do
      wait_present(:css,"div.wpb_wrapper > div > div > a[href=\"/life\"] > img")
      @session.find(:css,"div.wpb_wrapper > div > div > a[href=\"/life\"] > img").click
      @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
    end
  end

  def click_on_view_all_posts
    @session.execute_script("scroll(0, 1800)")
    @session.click_link('View All Posts')
    @session.find(:css,"div.posts-container > article:nth-of-type(1)")
  end

  def click_on_internship_read_more
    @session.execute_script("scroll(0, 2000)")
    if Capybara.current_driver == :safari
      @session.find(:css,"div.wpb_wrapper > a[href=\"/internship\"]").click
    else
      @session.find(:css,"div.wpb_wrapper > a[href=\"/internship\"] > span").click
    end
    @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
  end

  def check_referrals_exist?
    @session.within(:main_referrals_area) do
      @session.find(:css,"div.slides.flickity-enabled.is-draggable")
    end
  end

  def check_social_network_link_valid(link, index)
    if Capybara.current_driver == :safari
      @session.find(:css, "ul.social > li:nth-of-type(#{index}) > a[href=\"#{link}\"]")
    else
      @session.find(:css, "ul.social > li:nth-of-type(#{index}) > a[href=\"#{link}\"]")
    end
  end

  def get_contact
    Contact.new(@session)
  end

  def get_blog
    Blog.new(@session)
  end

  def get_about
    About.new(@session)
  end

  def get_our_work
    OurWork.new(@session)
  end

  def get_careers
    Careers.new(@session)
  end

  def get_expertise
    Expertise.new(@session)
  end

  def get_lifeat
    Lifeat.new(@session)
  end

  def get_internship
    Internship.new(@session)
  end

  def get_internship_projects
    InternshipProjects.new(@session)
  end

  def get_chat
    Chat.new(@session)
  end
end
