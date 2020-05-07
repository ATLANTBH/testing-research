class SingleBlog < Blog
  def click_on_blog_type
    @session.within(:specific_blog_area) do
      blog_type = @session.find(:css, "div.row.heading-title.hentry span.meta-category a:nth-of-type(1)").text
      @session.find(:css, "div.row.heading-title.hentry span.meta-category a:nth-of-type(1)").click
      opened_blog_type = @session.driver.browser.find_element(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
      blog_type.casecmp(opened_blog_type) ? true : false
    end
  end

  def check_blog_data(index)
    @session.within(:posts_container) do
      type = @session.find("//article[#{index}]/div[@class=\"inner-wrap animated\"]/div[@class=\"post-content\"]/div[@class=\"content-inner\"]/span").text
      # check blog date exists
      date = @session.find("//article[#{index}]/div[@class=\"inner-wrap animated\"]/div[@class=\"post-content\"]/div/div/div[@class=\"post-header\"]/span").text
      # check blog name exists
      name = @session.find("//article[#{index}]/div[@class=\"inner-wrap animated\"]/div[@class=\"post-content\"]/div/div/div[@class=\"post-header\"]/h3").text
      return [type, date, name]
    end
  end

  def check_social_media_share_exists?
      @session.find(:css, "i.heateorSssSharing.heateorSssFacebookBackground")
      @session.find(:css, "i.heateorSssSharing.heateorSssTwitterBackground")
      @session.find(:css, "i.heateorSssSharing.heateorSssLinkedinBackground")
      @session.find(:css, "i.heateorSssSharing.heateorSssRedditBackground")
      @session.find(:css, "i.heateorSssSharing.heateorSssMoreBackground")
  end

  def check_disquss_form_is_loaded?
    @session.find("//div[@class=\"comments-section\"]/div[@id=\"disqus_thread\"]")
  end
end