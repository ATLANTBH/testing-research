require 'yaml'
require 'appium_capybara'
require 'capybara/rspec'
require "chromedriver/helper"
require 'require_all'
require 'rspec/retry'
require 'aws-sdk-s3'
require_all './lib/'

class SetupBrowser

  attr_accessor :platform, :web, :mobile, :url, :retry, :fast_fail, :s3, :screenshots_path, :screenshots_enabled

  def initialize
    config = YAML.load(File.open('./config/environment.yaml'))['environment']
    self.platform  = config['platform']
    self.web       = config['web']
    self.mobile    = config['mobile']
    self.url       = config['url']
    self.retry     = config['retry']
    self.fast_fail = config['fast_fail']
    self.s3        = config['s3']
    self.screenshots_path = config['screenshots_path']
    self.screenshots_enabled = config['screenshots_enabled']

    Capybara.default_selector = :xpath
    Capybara.default_max_wait_time = 30
  end

  def close_browser
    @session.driver.quit  
  end

  def load_browser
    browser = self.web['driver']

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = 90
    client.open_timeout = 90

    if ENV['SELENIUM_GRID_URL']
      Capybara.app_host = self.url
      Capybara.run_server = false
      Capybara.register_driver(browser.to_sym) do |app|
        capabilities = Selenium::WebDriver::Remote::Capabilities.send(browser.to_sym)
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          http_client: client,
          url: "http://#{ENV['SELENIUM_GRID_URL']}/wd/hub",
          desired_capabilities: capabilities
        )
      end
    else
      Capybara.register_driver(browser.to_sym) do |app|
        Capybara::Selenium::Driver.new(app, :browser => browser.to_sym, http_client: client)
      end
    end

    # Set default driver
    Capybara.default_driver = browser.to_sym

    # When running tests in containerized environment with docker compose this is needed to wait for all containers to be ready
    if ENV['DOCKER_COMPOSE_WAIT']
      sleep ENV['DOCKER_COMPOSE_WAIT'].to_i
    end

    @read_timeout = 0
    @server_error_timeout = 0
    begin
      # Start Capybara session
      @session = Capybara::Session.new(browser.to_sym)
      @homepage = HomePage.new(@session, self.platform, nil)

      @session.driver.browser.manage.window.move_to(0,0)
      @session.driver.browser.manage.window.maximize unless browser.to_sym == :chrome

      @homepage.goto_homepage(self.url)
      @homepage
    rescue Net::ReadTimeout
      @read_timeout += 1
      unless @read_timeout > 3
        puts "Net::ReadTimeout error occured. Trying to launch browser session again..."
        sleep 5
        retry
      end
    rescue Selenium::WebDriver::Error::ServerError
      @server_error_timeout += 1
      unless @server_error_timeout > 3
        puts "Selenium::WebDriver::Error::ServerError occured. Trying to launch browser session again..."
        sleep 5
        retry
      end
    end
  end

  def load_appium
    desired_caps = get_desired_caps

    Capybara.register_driver(:appium) do |app|
      appium_lib_options = {
        server_url: desired_caps[:server_url]
      }
      all_options = {
        appium_lib: appium_lib_options,
        caps: desired_caps[:caps]
      }
      Appium::Capybara::Driver.new(
        app, 
        all_options
      )
    end

    Capybara.default_driver = :appium

    @session = Capybara::Session.new :appium
    # Rotate mobile screen with ORIENTATION env var
    if (self.mobile['orientation'] == 'portrait' or self.mobile['orientation'] == 'landscape')
      # Due to chromedriver issue on android, context switching is needed to perform rotate
      if self.platform == 'mobile_android'
        @session.driver.appium_driver.set_context('NATIVE_APP')
        @session.driver.rotate self.mobile['orientation'].to_sym
        @session.driver.appium_driver.set_context('WEBVIEW_1')
      elsif self.platform == 'mobile_ios'
        @session.driver.rotate self.mobile['orientation'].to_sym
      end
    end

    @homepage = HomePage.new(@session, self.platform, self.mobile['orientation'])
    @homepage.goto_homepage(self.url)
    @homepage
  end

  def get_desired_caps
    if self.platform == 'mobile_ios'
      {
        caps: {
          platformName: self.mobile['ios']['platform_name'],
          platformVersion: self.mobile['ios']['platform_version'],
          deviceName: self.mobile['ios']['device_name'],
          browserName: self.mobile['ios']['browser_name'],
          automationName: 'XCUITest'
        },
        server_url: self.mobile['server_url']
      }
    elsif self.platform == 'mobile_android'
      {
        caps: {
          platformName: self.mobile['android']['platform_name'],
          platformVersion: self.mobile['android']['platform_version'],
          deviceName: self.mobile['android']['device_name'],
          browserName: self.mobile['android']['browser_name'],
          chromedriverExecutable: self.mobile['android']['chrome_driver']
        },
        server_url: self.mobile['server_url']
      }
    end
  end
end
