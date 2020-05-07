submit_valid_contact_form_steps_failed=0
require './spec_helper'

name = "ABH"
email = "automation@atlantbh.com"
subject = "ABH automation test"
message = "Submit valid contact form passed successfully!"

describe "Submit valid contact form" do

  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if submit_valid_contact_form_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          submit_valid_contact_form_steps_failed += 1
        end
      end
    else
      example.run
    end
  end

  let(:main) { @homepage.get_main }
  let(:contact) { @homepage.get_main.get_contact }

  context "Click on navigation" do
    it "navigation bar pops up" do
      main.click_on_navigation
    end
  end

  context "Click on contact in navigation" do
    it "opens contact page" do
      main.close_slaask_popup_if_present
      contact_header = main.click_on_navigation_contact
      expect(contact_header).to match(/how to reach us/i)
    end
  end

  context "Fill in valid name, email, subject and message and send message" do
    it "fills in name" do
      contact.fill_in_name(name)
    end

    it "fills in email" do
      contact.fill_in_email(email)
    end

    it "fills in subject" do
      contact.fill_in_subject(subject)
    end

    it "fills in message" do
      contact.fill_in_message(message)
    end 

    it "clicks on send button" do
      contact.click_on_send_button
    end

    it "sends message successfully" do
      send_message = contact.get_send_contact_message_successfull
      expect(send_message).to eq("Your message was sent successfully. Thanks.")
    end
  end

  after(:all) do
    @homepage.close_browser
  end
end
