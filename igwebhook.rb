require 'open-uri'
require 'json'
require 'sinatra'
require 'pry'

BASE_URL = "https://www.instagram.com"



 def get_media(code)
  #this handles success path only so far
  handle_url = "https://i.instagram.com/api/v1/users/#{code}/info/"
  user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_6 like Mac OS X) AppleWebKit/604.5.6 (KHTML, like Gecko) Mobile/15D100 Instagram 37.0.0.9.96 (iPhone7,2; iOS 11_2_6; pt_PT; pt-PT; scale=2.34; gamut=normal; 750x1331)"
    begin
      payload = open("#{handle_url}", "User-Agent" => user_agent).read
      handle = JSON.parse(payload)
      handle.dig('user', 'username')
    rescue
      puts 'failed to return'
    end

 end

 #return a JSON of handles as results
 def get_tag_media_nodes(tag)
    url = "#{BASE_URL}/explore/tags/#{ tag }/?__a=1"
    begin
      handles_id_payload = JSON.parse( open( "#{url}" ).read )
    rescue
      return 'failed to return'
    end

    #TODO write a thread to handle openning up many requests
    handles_id_nodes = handles_id_payload.dig("graphql","hashtag","edge_hashtag_to_media","edges")
    count = 0
    handles = handles_id_nodes.map do |node|
      user_id = node.dig('node', 'owner', 'id') #2220296767279182718
      sleep(1)
      handle = get_media(user_id)
    end

    {:results => handles}
 end

# p get_tag_media_nodes('gopro')

get '/' do
  handles_payload = get_tag_media_nodes(params[:tag])
  content_type :json

  handles_payload.to_json
end
