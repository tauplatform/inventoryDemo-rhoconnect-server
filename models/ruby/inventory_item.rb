require 'json'
require 'rest_client'
require 'aws-sdk'

class InventoryItem < Rhoconnect::Model::Base


  def initialize(source)
    @base = 'http://taustore.herokuapp.com/inventory_items'



    #for Amazon S3 service you must define next three environment variables (or you should define it programatically):
    # export AWS_ACCESS_KEY_ID=SHSKJHS_example
    # export AWS_SECRET_ACCESS_KEY=KJHGKJHGKJHGKJHGKJHG_example
    # export AWS_DEFAULT_REGION=us-west-2
    @s3 = Aws::S3::Client.new()


    #@s3 = Aws::S3::Client.new(
    #  access_key_id: 'SHSKJHS_example',
    #  secret_access_key: 'KJHGKJHGKJHGKJHGKJHG_example',
    #  region: 'us-west-2'
    #)
    @bucket = Aws::S3::Bucket.new('inventory-demo', {:client => @s3})
    super(source)
  end

  def query(params=nil)
    puts "Query: #{params.to_s}"
    parsed = JSON.parse(RestClient.get("#{@base}.json").body)
    @result={}
    parsed.each do |item|
      @result[item["inventory_item"]["id"].to_s] = item["inventory_item"]
    end if parsed
    @result
  end

  def create(create_hash)
    puts "Create: #{create_hash}"
    res = RestClient.post(@base, :inventory_item => create_hash)
    # After create we are redirected to the new record.
    # We need to get the id of that record and return
    # it as part of create so rhosync can establish a link
    # from its temporary object on the client to this newly
    # created object on the server
    JSON.parse(
        RestClient.get("#{res.headers[:location]}.json").body
    )["inventory_item"]["id"]
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

    public_url = object.public_url

    puts "Public URL on server: #{public_url}"

    public_url
  end
end
