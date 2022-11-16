module GetTwitter
  def get_twitter(url, params, format: "json")
    options = {
      method: 'get',
      headers: {
        "Authorization" => "Bearer #{@bearer_token}"
        },
      params: params
    }
    
    request = Typhoeus::Request.new(url, options)
    response = request.run
    
    if format == "ruby"
        return JSON.parse(response.body.to_s) 
    elsif format == "code"
        return response.code 
    else
        return JSON.pretty_generate(JSON.parse(response.body))
    end
  end
end