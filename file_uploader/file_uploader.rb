require 'aws-sdk'

class FileUploader
  def initialize(options)
    credentials = Aws::Credentials.new(options['aws_access_key_id'], options['aws_secret_access_key'])
    options = options['endpoint'].nil? ? { region: options['region'] } : { region: 'none', endpoint: options['endpoint'], force_path_style: true }
    options[:credentials] = credentials
    @s3_resource = Aws::S3::Resource.new(options)
  end

  def upload_file(bucket, file_path, directory = '')
    file_name = directory + '/'+ file_path.split('/').last
    object = @s3_resource.bucket(bucket).object(file_name)
    object.upload_file file_path, acl: 'public-read'
    object.public_url
  end
end
