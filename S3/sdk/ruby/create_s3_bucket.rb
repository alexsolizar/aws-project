#!/usr/bin/env ruby

require 'aws-sdk-s3'
require 'securerandom'

# Check if the required arguments are provided
if ARGV.length != 3
  puts "Usage: #{$PROGRAM_NAME} <bucket_name> <region> <num_files>"
  exit 1
end

# Parameters
bucket_name = ARGV[0]   # Bucket name from command line
region = ARGV[1]        # AWS region from command line
num_files = ARGV[2].to_i # Number of files to generate from command line
file_prefix = "random_file" # Prefix for the file names

# Create an S3 client
s3 = Aws::S3::Client.new(region: region)

# Create the S3 bucket
begin
  s3.create_bucket(bucket: bucket_name, create_bucket_configuration: { location_constraint: region })
  puts "Bucket '#{bucket_name}' created successfully."
rescue Aws::S3::Errors::BucketAlreadyExists => e
  puts "Error: Bucket '#{bucket_name}' already exists. Please choose a different name."
  exit 1
rescue Aws::S3::Errors::ServiceError => e
  puts "Failed to create bucket: #{e.message}"
  exit 1
end

# Generate and upload random text files
num_files.times do |i|
  # Generate random content
  random_content = SecureRandom.base64(32)
  
  # Create a file with random content
  file_name = "#{file_prefix}_#{i + 1}.txt"
  File.open(file_name, 'w') { |file| file.write(random_content) }
  
  # Upload the file to the S3 bucket
  begin
    File.open(file_name, 'r') do |file|
      s3.put_object(bucket: bucket_name, key: file_name, body: file)
    end
    puts "Uploaded #{file_name} to s3://#{bucket_name}/"
  rescue Aws::S3::Errors::ServiceError => e
    puts "Failed to upload #{file_name}: #{e.message}"
  end
  
  # Ensure the file is closed before attempting to delete it
  if File.exist?(file_name)
    begin
      File.delete(file_name)
      puts "Deleted local file: #{file_name}"
    rescue Errno::EACCES => e
      puts "Permission denied to delete file #{file_name}: #{e.message}"
    end
  end
end

puts "Bucket #{bucket_name} populated with #{num_files} random text files."
