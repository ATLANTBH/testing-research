class Chat < Main
  def click_chat_button
    wait_present_with_click(:css, 'div#slaask-button')
  end

  def get_default_message_text
    @session.find(:css, 'div.slaask-message-body > p').text
  end

  def close_chat
    if @platform =~ /mobile/ and @orientation == 'portrait'
      @session.find(:css, 'div.slaask-widget-header-cross').click
     else
      click_chat_button
    end
    sleep 2
  end

  def check_if_widget_is_visible?
    @session.find(:css, 'div#slaask-widget').visible?
  end
end