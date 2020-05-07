class InternshipProjects < Main

  def check_sections_present
    #check if projects are present
    section_ids = ["test", "java", "iot", "datasci", "analytics", "uxui", "bigdata"]
    section_ids.each do |id|
      return false if !@session.find("//div[@id=\"#{id}\"]")
    end
    return true
  end

  def check_remaining_sections
    #check sections for all internship projects
    section_ids_left = ["test", "iot", "analytics", "bigdata"]
    section_ids_right = ["java", "datasci", "uxui"]
    section_ids_left.each do |x|
      return false if !@session.find("//div[@id=\"#{x}\"]//p[1]")
    end
    section_ids_right.each do |x|
      return false if !@session.find("//div[@id=\"#{x}\"]//p[1]")
    end
    return true
  end

  def click_to_apply
    @session.find_link('Click here ').click
    @session.find_link("Apply for this job") ? true : false
  end
end
