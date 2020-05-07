class Contact < Main
  def fill_in_name(name)
    @session.within(:contact_form) do
      @session.fill_in('your-name', with: name)
    end
  end

  def fill_in_email(email)
    @session.within(:contact_form) do
      @session.fill_in('your-email', with: email)
    end
  end

  def fill_in_subject(subject)
    @session.within(:contact_form) do
      @session.fill_in('your-subject', with: subject)
    end
  end

  def fill_in_message(message)
    @session.within(:contact_form) do
      @session.fill_in('your-message', with: message)
    end
  end

  def fill_in_email_subscribe(email)
    @session.within(:subscribe_contact_form) do
      @session.fill_in('your-email', with: email)
    end
  end

  def click_on_send_button
    @session.within(:contact_form) do
      @session.click_button('Send')
    end
  end

  def click_on_subscribe_button
    @session.within(:subscribe_contact_form) do
      @session.click_button('Subscribe')
    end
  end

  def get_subscribe_contact_message_successfull
    @session.within(:subscribe_contact_form) do
      @session.find(:css, "div.wpcf7-response-output.wpcf7-display-none.wpcf7-mail-sent-ok").text
    end
  end

  def get_send_contact_message_successfull
    @session.within(:contact_form) do
      @session.find(:css, "div.wpcf7-response-output.wpcf7-display-none.wpcf7-mail-sent-ok").text
    end
  end

  def get_send_contact_message_not_successfull
    @session.within(:contact_form) do
      @session.find(:css, "div.wpcf7-response-output.wpcf7-display-none.wpcf7-validation-errors").text
    end
  end

  def click_on_send_button_when_name_empty
    @session.within(:contact_form) do
      @session.click_button('Send')
      @session.find(:css, "span.wpcf7-form-control-wrap.your-name span.wpcf7-not-valid-tip").text
    end
  end

  def click_on_send_button_when_email_empty_or_invalid
    @session.within(:contact_form) do
      @session.click_button('Send')
      @session.find(:css, "span.wpcf7-form-control-wrap.your-email span.wpcf7-not-valid-tip").text
    end
  end

  def click_on_send_button_when_subject_empty
    @session.within(:contact_form) do
      @session.click_button('Send')
      @session.find(:css, "span.wpcf7-form-control-wrap.your-subject span.wpcf7-not-valid-tip").text
    end
  end

  def click_on_send_button_when_message_empty
    @session.within(:contact_form) do
      @session.click_button('Send')
      @session.find(:css, "span.wpcf7-form-control-wrap.your-message span.wpcf7-not-valid-tip").text
    end
  end

  def check_address_correct?
    @session.find("//p[contains(., \"Bosmal City Center\")]")
    @session.find("//p[contains(., \"Milana Preloga 12A\")]")
    @session.find("//p[contains(., \"71000 Sarajevo\")]")
  end

  def check_contact_email_correct?
    @session.find_link("contact@atlantbh.com")  
  end

  def check_jobs_email_correct?
    @session.find_link("jobs@atlantbh.com")
  end

  def check_read_more_exists?
    @session.find(:xpath, "//span[contains(text(), \"Read more\")]")
  end

  def check_map_iframe_exists?
    @session.find("//iframe[@id = \"iframe\"]")
  end

  def check_subscribe_button_exist?
    @session.find(:xpath, "//input[@value = \"Subscribe\"]")
  end

end