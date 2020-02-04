require 'json'
require 'rest_client'
require 'aws-sdk-s3'

class InventoryItem < Rhoconnect::Model::Base


  def initialize(source)
    @base = 'http://inventory-demo-backend.herokuapp.com/inventory_items'

    # for Amazon S3 service you must define next three environment variables (or you should define it programatically):
    # export AWS_ACCESS_KEY_ID=SHSKJHS_example
    # export AWS_SECRET_ACCESS_KEY=KJHGKJHGKJHGKJHGKJHG_example
    # export AWS_DEFAULT_REGION=us-west-2
    # in case of AWS bug please set one else environment variable :
    # export AWS_REGION=us-west-2
    # by documentation you should set AWS_DEFAULT_REGION but aws looking for AWS_REGION !!!

    @s3 = Aws::S3::Client.new()

    # bad style in case of your sources is public !
    #@s3 = Aws::S3::Client.new(
    #  access_key_id: 'SHSKJHS_example',
    #  secret_access_key: 'KJHGKJHGKJHGKJHGKJHG_example',
    #  region: 'us-west-2'
    #)

    @bucket = Aws::S3::Bucket.new('inventory-demo', {:client => @s3})
    super(source)
  end

  def query(params = nil)
    res = RestClient.get("#{@base}.json", {params: {username: current_user.login}, content_type: :json, accept: :json})
    parsed = JSON.parse(res.body)
    @result = {}
    parsed.each do |item|
      @result[item["id"].to_s] = item
    end if parsed
    @result
  end

  def create(create_hash)
    puts "Create: #{create_hash}"
    create_hash['username'] = current_user.login

    # After create we are redirected to the new record.
    # We need to get the id of that record and return
    # it as part of create so rhosync can establish a link
    # from its temporary object on the client to this newly
    # created object on the server

    RestClient.post(@base, :inventory_item => create_hash) { |response, request, result|
      case response.code
      when 302
        res = RestClient.get("#{response.headers[:location]}.json")
        data = JSON.parse(res.body)
        return data["id"]
      else
        puts "#{response.code} => #{response}"
        raise 'We expect here the response from the backend with code 302'
      end
    }
  end

  def update(update_hash)
    puts "Update: #{update_hash}"
    obj_id = update_hash['id']
    update_hash.delete('id')
    RestClient.put("#{@base}/#{obj_id}", :inventory_item => update_hash)
  end

  def delete(delete_hash)
    RestClient.delete("#{@base}/#{delete_hash['id']}")
  end

  def store_blob(obj, field_name, blob)
    puts "Store blob for field [#{field_name}] blob[#{blob.to_s}]"

    extension = File.extname(blob[:filename])
    key = "#{SecureRandom.uuid}#{extension}"

    object = @bucket.object(key)

    object.upload_file(blob[:tempfile].path, {:acl => 'public-read'})

    public_url = object.public_url.gsub("https://", "http://")

    puts "Public URL on server: #{public_url}"

    public_url
  end
end
