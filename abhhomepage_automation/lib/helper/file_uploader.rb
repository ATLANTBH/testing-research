class FileUploader
  attr_accessor :s3_resource

  def initialize(options)
    if options['aws_access_key_id'].nil? || options['aws_secret_access_key'].nil?
      raise ArgumentError.new("Please provide region") if options['region'].nil?
      @s3_resource = Aws::S3::Resource.new(region: options['region'])
    else
      credentials = Aws::Credentials.new(options['aws_access_key_id'], options['aws_secret_access_key'])
      options = options['endpoint'].nil? ? { region: options['region'] } : { region: 'none', endpoint: options['endpoint'], force_path_style: true }
      options[:credentials] = credentials
      @s3_resource = Aws::S3::Resource.new(options)
    end
  end

  def upload_file(bucket, file_path, bucket_path='')
    file_name = bucket_path + '/'+ file_path.split('/').last
    object = @s3_resource.bucket(bucket).object(file_name)
    object.upload_file file_path, acl: 'public-read'
    object.public_url
  end
end