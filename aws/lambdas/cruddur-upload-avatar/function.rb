require 'aws-sdk-s3'
require 'json'


def handler(event:, context:)


  allowed_origins = [
  
    "https://3000-ritammishra-awsbootcamp-pd2rwrjntmd.ws-us102.gitpod.io",

  ]

  origin = event['headers']['origin'] || event['headers']['Origin']

  if event["routeKey"] == "OPTIONS /{proxy+}"

    puts({step:'preflight', message:"preflight CORS check"}.to_json)

    { 
      headers: {
        "Access-Control-Allow-Headers": "*, Authorization",
        "Access-Control-Allow-Origin": allowed_origins.include?(origin) ? origin : "",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
      },
      statusCode: 200, 
    }
    
  else
    puts 'printing the events==='
    puts event
    puts 'printing the origin===='
    puts origin
    body_hash = JSON.parse(event["body"])
    extension = body_hash["extension"]
    
    cognito_user_id = event["requestContext"]["authorizer"]["lambda"]["sub"]

    puts({step:'presign url', sub_value: cognito_user_id}.to_json)
    

    s3 = Aws::S3::Resource.new
    bucket_name = ENV["UPLOADS_BUCKET_NAME"]
    object_key = "#{cognito_user_id}.#{extension}"

    puts({object_key: object_key}.to_json)
  
    obj = s3.bucket(bucket_name).object(object_key)
    url = obj.presigned_url(:put, expires_in: 60 * 5)
    url # this is the data that will be returned

  
    body = {url: url}.to_json
    
    { 
      headers: {
        "Access-Control-Allow-Headers": "*, Authorization",
        "Access-Control-Allow-Origin": allowed_origins.include?(origin) ? origin : "",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
      },
      statusCode: 200, 
      body: body 
      
    }
    
  end

end