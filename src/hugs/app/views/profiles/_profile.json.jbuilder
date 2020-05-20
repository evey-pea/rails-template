json.extract! profile, :id, :user_id, :name_first, :name_second, :name_display, :description, :street_number, :road, :suburb, :city, :state, :postcode, :country, :created_at, :updated_at
json.url profile_url(profile, format: :json)
