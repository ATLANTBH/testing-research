submit_invalid_contact_form_steps_failed=0
require './spec_helper'

name = "ABH"
email = "automation@atlantbh.com"
subject = "ABH automation test"
message = "Submit invalid contact!"

describe "Submit invalid contact form" do
  around(:example) do |example|
    if @is_fast_fail
      failed_steps_allowed=@fast_fail_steps
      if submit_invalid_contact_form_steps_failed < failed_steps_allowed
        example.run
        if example.exception
          submit_invalid_contact_form_steps_failed += 1
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

  context "Enter values for all fields except name" do
    it "fills in name" do
      contact.fill_in_name("")
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

    it "fails to send message successfully" do
      error_message = contact.click_on_send_button_when_name_empty
      message = contact.get_send_contact_message_not_successfull
      expect(message).to eq("Validation errors occurred. Please confirm the fields and submit it again.")
      expect(error_message).to eq("Please fill the required field.")
    end
  end

  context "Enter values for all fields except email" do
    it "fills in name" do
      contact.fill_in_name(name)
    end

    it "fills in email" do
      contact.fill_in_email("")
    end

    it "fills in subject" do
      contact.fill_in_subject(subject)
    end

    it "fills in message" do
      contact.fill_in_message(message)
    end

    it "fails to send message successfully" do
      error_message = contact.click_on_send_button_when_email_empty_or_invalid
      message = contact.get_send_contact_message_not_successfull
      expect(message).to eq("Validation errors occurred. Please confirm the fields and submit it again.")
      expect(error_message).to eq("Please fill the required field.")
    end
  end

  context "Enter values for all fields except subject" do
    it "fills in name" do
      contact.fill_in_name(name)
    end

    it "fills in email" do
      contact.fill_in_email(email)
    end

    it "fills in subject" do
      contact.fill_in_subject("")
    end

    it "fills in message" do
      contact.fill_in_message(message)
    end

    it "fails to send message successfully" do
      error_message = contact.click_on_send_button_when_subject_empty
      message = contact.get_send_contact_message_not_successfull
      expect(message).to eq("Validation errors occurred. Please confirm the fields and submit it again.")
      expect(error_message).to eq("Please fill the required field.")
    end
  end

  context "Enter values for all fields except message" do
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
      contact.fill_in_message("")
    end

    it "fails to send message successfully" do
      error_message = contact.click_on_send_button_when_message_empty
      message = contact.get_send_contact_message_not_successfull
      expect(message).to eq("Validation errors occurred. Please confirm the fields and submit it again.")
      expect(error_message).to eq("Please fill the required field.")
    end
  end

  context "Enter valid values for all fields except invalid email" do
    it "fills in name" do
      contact.fill_in_name(name)
    end

    it "fills in email" do
      contact.fill_in_email("invalid_email_format")
    end

    it "fills in subject" do
      contact.fill_in_subject(subject)
    end

    it "fills in message" do
      contact.fill_in_message(message)
    end
    
    it "fails to send message successfully" do
      error_message = contact.click_on_send_button_when_email_empty_or_invalid
      message = contact.get_send_contact_message_not_successfull
      expect(message).to eq("Validation errors occurred. Please confirm the fields and submit it again.")
      expect(error_message).to eq("Please enter a valid email address.")
    end
  end

  after(:all) do
    @homepage.close_browser
  end
end
