require 'appium_lib'
require './spec/spec_helper'

describe "Basic test" do

	before :all do
    Appium::Driver.new(@desired_caps.caps).start_driver
    Appium.promote_appium_methods RSpec::Core::ExampleGroup
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Attractions field" do
			expect(exists { find 'Attractions' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Restaurants and Cafes field" do
			expect(exists { find 'Restaurants and Cafes' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Nightlife field" do
			expect(exists { find 'Nightlife' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Shopping field" do
			expect(exists { find 'Shopping' }).to eq(true)
		end
	end

	context "Swipe to bottom of homepage" do
		it "Bottom buttons are visible" do
			Appium::TouchAction.new.swipe(start_x: 200, start_y: 500, end_x: 50, end_y: -400, duration: 500).perform
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Transportation field" do
			expect(exists { find 'Transportation' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Take a selfie field" do
			expect(exists { find 'Take a selfie' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains 3 Days in Melbourne field" do
			expect(exists { find '3 Days in Melbourne' }).to eq(true)
		end
	end

	context "Open Tourist Guide application" do
		it "application homepage is displayed and contains Tours field" do
			expect(exists { find 'Tours' }).to eq(true)
		end
	end

	after :all do
		driver_quit
	end
end
