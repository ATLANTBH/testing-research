class Blog < Main
  def click_on_first_blog
    @session.within(:posts_container) do
      @session.execute_script("scroll(0, 1500)")
      if Capybara.current_driver == :safari || @platform == 'mobile_ios'
        @session.find(:css,"article:nth-of-type(1) > div.inner-wrap > div.post-content > a").click
      else
        @session.find(:first_blog).click
      end
      @session.driver.browser.find_element(:css,"span.meta-author.vcard.author > span > a") ? true : false
    end
  end

  def click_on_specific_blog(index)
    @session.within(:posts_container) do
      if Capybara.current_driver == :safari || @platform == 'mobile_ios'
        @session.find(:specific_blog_safari, index).click
      else
        @session.find(:specific_blog, index).click
      end
      @session.driver.browser.find_element(:css,"span.meta-author.vcard.author > span > a") ? true : false
    end
  end

  def click_on_specific_blog_type(index)
    @session.within(:posts_container) do
      blog_type = @session.find(:css,"article:nth-of-type(#{index}) > div.inner-wrap > div.post-content > div > span").text
      @session.find(:css,"article:nth-of-type(#{index}) > div.inner-wrap > div.post-content > div > span").click
      opened_blog_type = @session.driver.browser.find_element(:css,"div.inner-wrap > h1").text
      blog_type.casecmp(opened_blog_type) ? true : false
    end
  end

  def check_blog_data(index)
    @session.within(:posts_container) do
      # check blog type exists
      type = @session.find(:css,"article:nth-of-type(#{index}) > div.inner-wrap > div.post-content > div.content-inner > span").text
      # check blog name exists
      name = @session.find(:css,"article:nth-of-type(#{index}) > div.inner-wrap > div.post-content > div > div > div.post-header > h3").text
      return [type, name]
    end
  end

  def get_single_blog
    SingleBlog.new(@session)
  end

  def get_blog_group
    BlogGroup.new(@session)
  end
end