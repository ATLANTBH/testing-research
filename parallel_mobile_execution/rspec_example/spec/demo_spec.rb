require 'appium_lib'
require './spec/spec_helper'

address = "Maršala Tita 26"
place_name = "Multiplex Cinema City"

describe "Basic search test" do

	before :all do
    Appium::Driver.new(@desired_caps.caps).start_driver
    Appium.promote_appium_methods RSpec::Core::ExampleGroup
	end

	context "Open Navigator application" do
		it "application homepage is displayed and contains search field" do
			expect(exists { find_exact 'Search' }).to eq(true)
		end
	end

	context "Click on the search field and search for place: #{place_name}" do
		it "Search has been completed and place with name #{place_name} has been found" do
			wait { tags("android.widget.LinearLayout")[0].send_keys place_name }
			sleep 5
			x_coordinate = tags("android.widget.LinearLayout")[0].location.x
      y_coordinate = tags("android.widget.LinearLayout")[0].location.y
      # increase coordinates so it can be clicked on dropdown menu
			Appium::TouchAction.new.tap(x: x_coordinate + 100, y: y_coordinate + 100).perform
			wait { expect(exists {find_exact place_name}).to eq(true) }
		end
	end

	context "Check that place contains address info" do
		it "Place contains address info" do
			wait { expect(id('com.atlantbh.navigator:id/profile_address').text).to include(address) }
		end
	end

	after :all do
		driver_quit
	end
end