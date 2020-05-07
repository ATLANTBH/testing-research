class Internship < Main
  def click_internship_projects
    @session.find_link('PICK A PROJECT').click
    @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
  end

  def click_internship_stories
    @session.find_link('Read their stories').click
    @session.find(:xpath,"//div[@class=\"inner-wrap\"]/h1").text
  end 
end