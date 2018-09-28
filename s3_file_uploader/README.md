# S3 File uploader

FileUploader is a helper ruby class that is used to upload files to an S3 storage.
Main idea behind this is ability for OWL test reporting tool to be able to show screenshots of failed test steps which will be loaded from S3

# Pre-requisities
You can use this script just to store screenshots of your failed test steps but it will make more sense to use it in broader sense with OWL tool which will enable automatical retrieval of screenshots you store in S3.
1. You can install OWL test reporting tool following instructions on: https://github.com/ATLANTBH/owl (OWL only has ability to show screenshots that are already on S3). You need to enable screenshot capture ability on owl by modifying `application.properties` file and adding following:
```
# Show failed test steps screenshots
project.features.screenshot.url=true
```
2. You need to use rspec2db gem in order to store results to database (along with the S3 link to the object - screenshot which will be used and shown on OWL since OWL uses same database that rspec2db seeded in order to show test results). You can find instructions on how to install and setup rspec2db on: https://github.com/ATLANTBH/rspec
3. Create S3 bucket on AWS which will be used to store screenshots 
4. In order to upload screenshots to S3, you will need to either have set of aws keys (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) or your machine (from which you are running tests) is already on AWS EC2 and, in that case, it is much better and safer to setup IAM role and attach its profile to the running EC2 instance so you don't explicitly use aws keys. For the safety concerns, this IAM role should have policy that looks like this:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::<BUCKET_NAME>",
                "arn:aws:s3:::<BUCKET_NAME>/*"
            ]
        }
    ]
}
```
This script will support both cases (with and without explicit aws keys).

## Usage 
When all steps from pre-requisities sections are completed, you can use file uploader script in following way:
```
file_path = '/tmp/file.txt`
bucket_name = 'sample_bucket_name'
bucket_path = '/path/in/bucket'

options = {
  'aws_access_key_id' => ENV['AWS_ACCESS_KEY_ID'],
  'aws_secret_access_key' => ENV['AWS_SECRET_ACCESS_KEY'],
  'region' => ENV['region']
}

file_uploader = FileUploader.new(options)

puts file_uploader.upload_fle(bucket_name, file_path, bucket_path) ### 'outputs the url of the file on s3 storage`
```

## How to incorporate this functionality inside your RSpec test suite?
First, you need to add this script in your test suite. Suppose, you have following test suite structure:

```
$ tree -L 1
.
├── Gemfile
├── Gemfile.lock
├── config
├── lib
├── spec
└── spec_helper.rb
```

You can add this script in `./lib/file_uploader.rb` directory and make sure it is required in your `spec_helper.rb` as well as `aws-sdk-s3`

For example:
```
require 'aws-sdk-s3'
require_all './lib/'
```

In your `config` folder, you can add yaml structure which contains data needed to upload file to S3. For example:
```
environment:
  screenshots_path: '/tmp/screenshots'
  s3:
    region: 'us-east-1'
    bucket: 'abh-website-tests'
    directory: 'failed_test_case_screenshots'
```

Finally, you need to call file_uploader script in your `spec_helper.rb` file after each rspec example that is executed if that same example contains exception which would mean that screenshot needs to be captured. That specific block in your `spec_helper.rb` is called `config.after(:each)`. This is an example:
```
# assumption is that setup object captures your yaml file where your environment related stuff is located

  config.after(:each) do |example|
    array_of_exceptions_not_suitable_for_screenshots = ["Net::ReadTimeout", "Selenium::WebDriver::Error::ServerError", "Selenium::WebDriver::Error::UnknownError", "Selenium::WebDriver::Error::SessionNotCreatedError"]
    if ((example.exception != nil) && (!array_of_exceptions_not_suitable_for_screenshots.include? example.exception.message))
      screenshot_name = setup.screenshots_path + example.description  + ' @' + Time.now.to_i.to_s + '.png'
      screenshot_name.gsub! ' ', '_'
      puts "Saving screenshot: " + screenshot_name

      # Capybara's way of saving screenshot. You can use any web driver related library like Watir to do the same
      @homepage.session.save_screenshot(screenshot_name)

      @rspec_reporter.publish :screenshot_saved, screenshot_path: screenshot_name, example: example.description
      if setup.s3
        puts 'Uploading screenshot to S3'
        file_uploader = FileUploader.new setup.s3
        screenshot_url = file_uploader.upload_file(setup.s3['bucket'], screenshot_name, setup.s3['directory'])
        @rspec_reporter.publish :screenshot_uploaded, screenshot_url: screenshot_url, example: example.description
      end
    end
  end
```
