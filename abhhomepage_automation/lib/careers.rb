class Careers < Main
  def check_offers_exist?
    @session.driver.browser.find_element(:xpath, "//div[@class=\"wpb_row vc_row-fluid vc_row standard_section   \"]")
  end

  def click_see_available_jobs
    @session.find(:css, "a[href='https://atlantbh.workable.com/']").click
    # switch to newly opened "Workable" window
    sleep_firefox(3)
    sleep_chrome(3)
    @session.driver.browser.switch_to.window(@session.driver.browser.window_handles.last)
    sleep_firefox(3)
    sleep_chrome(3)
    @session.find(:css, "section#jobs") ? true : false
  end
end