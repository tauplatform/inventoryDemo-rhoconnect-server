require 'json'
require 'rest_client'

class Report < Rhoconnect::Model::Base

  def initialize(source)
    @base = 'http://taustore.herokuapp.com/reports'
    super(source)
  end

  def query(params=nil)
    parsed = JSON.parse(RestClient.get("#{@base}.json").body)

    @result={}
    parsed.each do |item|
      @result[item["report"]["id"].to_s] = item["report"]
    end if parsed
  end

  def create(create_hash)
    res = RestClient.post(@base, :report => create_hash)

    # After create we are redirected to the new record.
    # We need to get the id of that record and return
    # it as part of create so rhosync can establish a link
    # from its temporary object on the client to this newly
    # created object on the server
    JSON.parse(
        RestClient.get("#{res.headers[:location]}.json").body
    )["report"]["id"]
  end

  def update(update_hash)
    obj_id = update_hash['id']
    update_hash.delete('id')
    RestClient.put("#{@base}/#{obj_id}", :report => update_hash)
  end

  def delete(delete_hash)
    RestClient.delete("#{@base}/#{delete_hash['id']}")
  end

  def store_blob(obj, field_name, blob)
    puts ">>>>>>>>>>>>>>>>>>>>>> store_blob in model"
    puts "#{obj}"
    puts "#{field_name}"
    puts "#{blob}"
    response = RestClient.post(
        'https://taustore.herokuapp.com/upload',
        :file => File.new(blob[:tempfile].path, 'rb'),
        :accept => :json
    )
    json = JSON.parse(response.body)
    puts "response json #{json}"
    blob[:filename]
  end
end


def store_blob(obj, field_name, blob)
  puts ">>>>>>>>>>>>>>>>>>>>>> store_blob outside model"
  puts "#{obj}"
  puts "#{field_name}"
  puts "#{blob}"
  response = RestClient.post(
      'https://taustore.herokuapp.com/upload',
      :file => File.new(blob[:tempfile].path, 'rb'),
      :accept => :json
  )
  json = JSON.parse(response.body)
  puts "response json #{json}"
  blob[:filename]
end