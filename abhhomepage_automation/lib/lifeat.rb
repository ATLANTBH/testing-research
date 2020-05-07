class Lifeat < Main

  def check_expertise_exists?
    @session.find("//div[@id=\"expertise\"]")
  end

  def check_intro_exists?
    #check intro text exists
    @session.execute_script("scroll(0, 400)")
    sleep 3
    @session.find(:xpath,"//div[@id=\"life\"]//div[contains(@class,\"instance-1\")]//p").text
  end

  def click_first_casestudy
    @session.find_link("READ OUR BLOGS").click
    if Capybara.current_driver == :safari && @platform != 'mobile_ios'
      @session.find(:xpath, "//div[@class=\"inner-wrap\"]/h3").text
    else
      wait_present(:xpath,"//div[@class=\"inner-wrap\"]/h1")
      wait_until_text_present(@session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1"), "Blog")
      @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
    end
  end

  def click_second_casestudy
    @session.find_link("MEET OUR DRIVE").click
    if Capybara.current_driver == :safari && @platform != 'mobile_ios'
      @session.find(:xpath, "//div[@class=\"inner-wrap\"]/h3").text
    else
      wait_present(:xpath,"//div[@class=\"inner-wrap\"]/h1")
      wait_until_text_present(@session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1"), "Atlanters In Focus")
      @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
    end
  end

  def check_joinnow_exists?
    @session.find(:css,"a.nectar-button.large.join-now-internship-btn")
  end

  def check_joinnow_works?
   if Capybara.current_driver == :safari && @platform != 'mobile_ios'
     @session.find(:css,"a.nectar-button.large.join-now-internship-btn").click
     current_url = @session.driver.browser.current_url
   else
     @session.find(:css,"a.nectar-button.large.join-now-internship-btn").click
     current_url = @session.driver.browser.current_url
   end
   current_url
  end
end
