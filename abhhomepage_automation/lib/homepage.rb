class HomePage
  attr_accessor :session, :platform, :orientation, :wait

  def initialize(session, platform=nil, orientation=nil)
    @session = session
    @platform = platform
    @orientation = orientation
  end

  def goto_homepage(host_url)
    @session.visit(host_url)
  end

  def click_back
    # Commented out since it can cause an issue with losing selenium webdriver session (Selenium::WebDriver::Error::ServerError)
    #@session.go_back
    sleep 5
    @session.evaluate_script("window.history.go(-1)")
    sleep 5
  end

  def get_main
    Main.new(@session, @platform, @orientation)
  end

  def sleep_chrome(interval)
    sleep interval if Capybara.current_driver == :chrome
  end

  def sleep_firefox(interval)
    sleep interval if Capybara.current_driver == :firefox
  end

  def sleep_safari(interval)
    sleep interval if Capybara.current_driver == :safari
  end

  def click_with_retry(element, next_element, max_click=10, interval=1)
    i = 1
    begin
      while (@session.has_xpath?(element, wait: 5) and i<max_click)
        i = i+1
        if !@session.has_xpath?(next_element, wait: 5)
          @session.find(element).click
          sleep interval
        else
          break
        end
      end
    rescue Capybara::ElementNotFound
      puts "Element not visible...trying again for #{i} time..."
      retry
    end
  end

  def wait_present(selector, element)
    i = 1
    count = 10
    interval = 1
    begin
      while (i<count)
        sleep interval
        i = i+1
        @session.find(selector, element)
        break
      end
    rescue Capybara::ElementNotFound
      puts "Element not visible...trying again for #{i} time..."
      retry
    end
  end

  def wait_present_with_click(selector, element)
    i = 1
    count = 10
    interval = 1
    begin
      while (i<count)
        sleep interval
        i = i+1
        @session.find(selector, element)
        @session.find(selector, element).click
        break
      end
    rescue Capybara::ElementNotFound
      puts "Element not visible...trying again for #{i} time..."
      retry
    end
  end

  def wait_until_text_present(element, text)
    i = 1
    count = 20
    interval = 1
    while !(element.text == text or i>count)
      sleep interval
      puts "Couldn't get element text...Trying again for #{i} time..."
      i = i+1
    end
  end

  def close_browser
    if ENV['SELENIUM_GRID_URL'].to_s.empty?
      if @platform == 'web'
        puts "Quitting browser session..."
        Capybara.current_driver == :firefox ? @session.driver.browser.close : @session.driver.browser.quit
      end
      if @platform =~ /mobile/
        puts "Closing mobile session..."
        @session.driver.browser.close
      end
    end
  end
end