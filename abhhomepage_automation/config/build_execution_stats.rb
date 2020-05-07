require 'rubygems'
require 'yaml'
require 'active_record'

class TestRun < ActiveRecord::Base
  # "testrun" records time of the test execution, duration, pass rate
  # and contains build number as specified in the yml configuration file
  has_many :testcases
  belongs_to :testsuite
end

dbconfig = YAML.load(File.open('./config/rspec2db.yml'))
ActiveRecord::Base.establish_connection(dbconfig['dbconnection'])

build_id = ARGV[0]
file_name = ARGV[1]
retrieve_limit = ARGV[2]
test_reporter_url = ARGV[3]
test_suite_name = dbconfig['options']['suite']

if retrieve_limit == nil
  @query = "select tr.* from test_runs tr, test_suites ts where ts.id = tr.test_suites_id and tr.build LIKE '#{build_id}' and ts.suite LIKE '#{test_suite_name}' order by tr.created_at desc limit 1"
elsif retrieve_limit == 'all'
  @query = "select tr.* from test_runs tr, test_suites ts where ts.id = tr.test_suites_id and tr.build LIKE '#{build_id}' and ts.suite LIKE '#{test_suite_name}' order by tr.created_at desc"
else 
  raise Exception, 'Invalid parameter value.'
end

report = "Execution stats:\n"
report << "----------------\n"

@build = ""
@success_rate = []
@test_steps_count = 0
@test_steps_pass_count = 0
@test_steps_failed_count = 0
@duration = 0
@test_run_id = 0

@test_runs = TestRun.find_by_sql(@query)
@test_runs.each do |test_run|
  @success_rate << ((test_run.example_count.to_i - test_run.failure_count.to_i).to_f / test_run.example_count.to_f) * 100
  @test_steps_count = @test_steps_count + test_run.example_count
  @test_steps_pass_count = @test_steps_pass_count + (test_run.example_count.to_i - test_run.failure_count.to_i)
  @test_steps_failed_count = @test_steps_failed_count + test_run.failure_count
  if test_run.duration>@duration
    @duration = test_run.duration
  end
  @build = test_run.build
  @test_run_id = test_run.id
end

@rate = ( @test_steps_pass_count.to_f / @test_steps_count.to_f ) * 100
@formatted_rate = sprintf('%.2f', @rate.to_f)
@formatted_duration = sprintf('%.2f', @duration.to_f)

if test_reporter_url == nil
  File.open(file_name, 'w') { |f| f.write("#{report}Build name: #{@build}\nDuration: #{@formatted_duration}s\nSuccess rate: #{@formatted_rate}%\nTest steps count: #{@test_steps_count}\nTest steps passed: #{@test_steps_pass_count}\nTest steps failed: #{@test_steps_failed_count}\n") }
else
  File.open(file_name, 'w') { |f| f.write("#{report}Build name: #{@build}\nDuration: #{@formatted_duration}s\nSuccess rate: #{@formatted_rate}%\nTest steps count: #{@test_steps_count}\nTest steps passed: #{@test_steps_pass_count}\nTest steps failed: #{@test_steps_failed_count}\nTest reporter page: #{test_reporter_url}/test-runs/#{@test_run_id}/test-cases\n") }
end

sql = "select count(tc.test_group) from test_suites ts, test_runs tr, test_cases tc where ts.id=tr.test_suites_id and tr.id=tc.test_runs_id and tr.build='#{build_id}' and ts.suite='#{test_suite_name}' group by tc.test_group"
number_of_scripts = TestRun.find_by_sql(sql)

File.open(file_name, 'a') { |f| f.puts "Number of test scripts: #{number_of_scripts.count}"}

sql_failed="select count(tc.test_group) from test_suites ts, test_runs tr, test_cases tc where ts.id=tr.test_suites_id and tr.id=tc.test_runs_id and tr.build='#{build_id}' and ts.suite='#{test_suite_name}' and tc.execution_result='failed' group by tc.test_group"

number_of_failed_scripts=TestRun.find_by_sql(sql_failed)
File.open(file_name, 'a') { |f| f.puts "Number of failed scripts: #{number_of_failed_scripts.count}"}