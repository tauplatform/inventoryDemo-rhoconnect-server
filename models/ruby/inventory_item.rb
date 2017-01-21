require 'json'
require 'rest_client'

class InventoryItem < Rhoconnect::Model::Base

  def initialize(source)
    @base = 'http://taustore.herokuapp.com/inventory_items'
    super(source)
  end

  def query(params=nil)
    parsed = JSON.parse(RestClient.get("#{@base}.json").body)

    @result={}
    parsed.each do |item|
      @result[item["inventory_item"]["id"].to_s] = item["inventory_item"]
    end if parsed
  end

  def create(create_hash)
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
    obj_id = update_hash['id']
    update_hash.delete('id')
    RestClient.put("#{@base}/#{obj_id}", :inventory_item => update_hash)
  end

  def delete(delete_hash)
    RestClient.delete("#{@base}/#{delete_hash['id']}")
  end

  def store_blob(obj, field_name, blob)
    extension = File.extname(blob[:filename])
    filename = "#{SecureRandom.uuid}#{extension}"
    url = 'http://taustore.herokuapp.com/upload'

    response = RestClient.post(url, {
        :file => File.new(blob[:tempfile].path, 'rb'),
        :filename => filename,
        :accept => :json
    })

    json = JSON.parse(response.body)
    json['filename']
  end
end