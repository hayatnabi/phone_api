class Api::V1::PhoneLookupController < ApplicationController
  def lookup
    phone = params[:phone]

    if phone.blank?
      return render json: { error: 'Phone number is required' }, status: :bad_request
    end

    data = fetch_phone_data(phone)

    if data
      render json: data
    else
      render json: { error: 'Failed to fetch phone data' }, status: :bad_gateway
    end
  end

  private

  def fetch_phone_data(phone)
    api_key = ENV['NUMVERIFY_API_KEY']
    url = "http://apilayer.net/api/validate?access_key=#{api_key}&number=#{phone}&format=1"

    response = HTTParty.get(url)

    if response.success?
      json = response.parsed_response
      {
        number: json["international_format"],
        valid: json["valid"],
        location: json["location"],
        carrier: json["carrier"],
        line_type: json["line_type"]
      }
    else
      nil
    end
  end
end
