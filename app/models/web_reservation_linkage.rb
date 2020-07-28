class WebReservationLinkage
  BASE_URL = "#{ENV['WEB_RESERVE_URL']}/api/"
  DEFAULT_OPTIONS = { content_type: :json, accept: :json }

  def initialize
    get_api_token
  end

  def get_api_token
    response = RestClient.post("#{BASE_URL}sign_in.json", {login_name: ENV['API_LOGIN_NAME'], password: ENV['API_PASSWORD']}, DEFAULT_OPTIONS)
    login = JSON.parse(response.body)
    @authenticate_token = "Bearer #{login['token']}"
  end

  def send_master
    response = RestClient.get("#{url_base}master_updated_at.json", options)
    puts "response #{response.body}"
    master_updated_at = JSON.parse(response.body)

    master = Item.web_master(master_updated_at['items'])
    if master.length > 0
      RestClient.post("#{url_base}upsert_items.json", {items: master.to_json}, options)
    end
  end
end
