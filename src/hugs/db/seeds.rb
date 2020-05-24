# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Add names of hugtypes to database (required)
huglist = Huglist.create([{ hugtype: "simple" }, { hugtype: "warm" }, { hugtype: "cuddle" }, { hugtype: "tight" }, { hugtype: "long" }, { hugtype: "buddy" }, { hugtype: "squishy" }, { hugtype: "bear" }])

#  Add fake user accounts
require "faker"

# Default user email and password for testing
test_email_base = ["cas012020", "@coderacademy.edu.au"]
test_password = "test1234"

# List of verified addresses from Map Crunch
address_book = [
  { street_number: "36", road: "Kardan Cct", suburb: "Karawara", state: "WA", postcode: "6152" },
  { street_number: "29", road: "Campbell St", suburb: "Traralgon", state: "Vic", postcode: "3844" },
  { street_number: "175", road: "Atlantic Dr", suburb: "Keysborough", state: "VIC", postcode: "3173" },
  { street_number: "5", road: "Gidya Rd", suburb: "Mudgeeraba", state: "QLD", postcode: "4123" },
  { street_number: "46", road: "Whyalla Pl", suburb: "Prestons", state: "NSW", postcode: "2170" },
  { street_number: "71", road: "Shrives Rd", suburb: "Narre Warren South", state: "VIC", postcode: "3805" },
  { street_number: "2", road: "Duke St", suburb: "West Launceston", state: "TAS", postcode: "7249" },
  { street_number: "58", road: "Oaklands Rd", suburb: "Somerton Park", state: "SA", postcode: "5044" },
  { street_number: "325", road: "Toohey Rd", suburb: "Tarragindi", state: "Qld", postcode: "6106" },
  { street_number: "27", road: "Barbet Pl", suburb: "Burleigh Waters", state: "QLD", postcode: "4220" },
]

# Profile 'About me descriptions'

descriptions = [
  { description: "I need hug" },
  { description: "Hug, hug ,HUUUGG!" },
  { description: "Wassup?" },
  { description: "Bear (hug) with me" },
  { description: "Stop. Cuddle time!" },
  { description: "No creeps please" },
  { description: "Who needs a hug?" },
  { description: "Netflix and hug?" },
  { description: "Hi, I'm new here" },
  { description: "I have snacks" },
]

# Add fake names to the addresses
profiles = []
profilecount = 0

# Build profiles for db population
for address in address_book
  # Create faked names to address hash
  names = { name_display: Faker::Name.last_name, name_first: Faker::Name.first_name, name_second: Faker::Name.last_name }
  # Reference description list
  description = descriptions[profilecount]
  # Merge hashes to form single hash
  profile = { **names, **description, **address }
  # Push resulting hash to profiles array
  profiles.push(profile)
  profilecount += 1
end

# Generate a random hug list
def random_hugs
  huglist_sample = []
  5.times { huglist_sample.push(Huglist.all.sample[:id]) }
  return huglist_sample.uniq
end

# Generate users with profiles in database
email_index = 0
for profile in profiles
  # Create user
  user = User.create(email: "#{test_email_base[0]}-#{email_index}#{test_email_base[1]}", password: "test1234")
  user_id = { user_id: user["id"] }
  # Create user's profile
  p new_profile = Profile.create(profile.merge(user_id))
  # Add random hug preferences to profile
  p new_profile.huglist_ids = random_hugs
  email_index += 1
end
