require './lib/main'

class About < Main

  def check_expertise_exists?
    @session.find("//div[@id=\"expertise\"]")
  end

  def check_intro_exists?
    #check intro text exists
    @session.execute_script("scroll(0, 400)")
    sleep 3
    @session.find(:xpath,"//div[@id=\"about\"]//div[contains(@class,\"instance-1\")]//p").text
  end

  def check_careers_exists?
    @session.find("//div[@id=\"careers\"]")
  end

  def click_first_casestudy
    @session.find_link("SEE OUR SKILLS").click
    wait_present(:xpath,"//div[@class=\"inner-wrap\"]/h1")
    wait_until_text_present(@session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1"), "Expertise")
    @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
  end

  def click_second_casestudy
    @session.find_link("LIVE THE CULTURE").click
    wait_present(:xpath,"//div[@class=\"inner-wrap\"]/h1")
    wait_until_text_present(@session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1"), "Careers @ Atlantbh")
    @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
  end

  def check_subscribe_exists?
    @session.find("//div[@id=\"wpcf7-f7120-p11318-o1\"]")
  end
end
