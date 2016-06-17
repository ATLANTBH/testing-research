require 'appium_lib'
require './spec/spec_helper'

describe "Basic test" do

	before :all do
    Appium::Driver.new(@desired_caps.caps).start_driver
    Appium.promote_appium_methods RSpec::Core::ExampleGroup
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Favorites field" do
			expect(exists { find_exact 'Favorites' }).to eq(true)
		end
	end

	after :all do
		driver_quit
	end
end