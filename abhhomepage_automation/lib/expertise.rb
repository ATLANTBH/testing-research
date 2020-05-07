class Expertise < Main
  def check_sections_present
    links = ["Start-Ups", "Enterprises", "Geospatial Location-based systems", "Data Science"]
    links.each do |x|
      return false if !@session.find("//p[contains(text(), \"#{x}\")][1]").click
    end
    return true
  end

  def check_subscribe_exists?
    @session.find("//div[@id=\"wpcf7-f7120-p12048-o1\"]")
  end
end
