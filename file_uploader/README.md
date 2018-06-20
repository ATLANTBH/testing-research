# S3 File uplaoder

FileUploader is a helper ruby class that is used to upload files to an S3 storage.

## Usage 

```
file_path = '/tmp/file.txt`
bucket_name = 'sample_bucket_name'
bucket_path = '/path/in/bucket'

file_uploader = FileUploader.new(aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])

puts file_uploader.upload_fle(bucket_name, file_path, bucket_path) ### 'outputs the url of the file on s3 storage`
```

