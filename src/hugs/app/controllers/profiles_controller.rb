class ProfilesController < ApplicationController
  respond_to :html, :js
  before_action :authenticate_user!
  before_action :set_user_profile, only: [:index, :show, :edit, :search_nearby, :update, :destroy]
  before_action :set_user_id, only: [:new, :edit]
  before_action :list_hugs, only: [:new, :edit]
  before_action :set_profile, only: [:show]
  before_action :profile_distance, only: [:show]
  before_action :set_block_lists, only: [:index, :search_best_match, :search_nearby]
  before_action :search_params, only: [:search_nearby]

  # GET /profiles
  # GET /profiles.json
  def index
    @excluded = (@blocked_by_list << @blocked_list).flatten!
    @excluded.push(current_user["id"])
    @profiles = Profile.where.not(user_id: @excluded)
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile_hugs = @profile.huglists.pluck(:hugtype).join(", ").capitalize
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    p params["1"]
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_best_match
    @search_heading = "Find your best matching fellow huggers"
    puts "user.profile.id: #{current_user.profile.id}"
    @hugs = find_hug_matches(current_user.profile.id)
    @matched_hugs = group_hugs(@hugs[1])
    @matchlist = verbose_hugs(@matched_hugs)
    @search_results = hug_score_sort(@matched_hugs)
    @profiles = profile_results(@search_results)
    @show_table = true
  end

  def search_nearby
    @search_heading = "Search Nearby"
    p @range = search_params[:range].to_i
    if @range != nil
      @profiles = find_near_profile(@profile, search_params[:range])
      @search_result_heading = "Search results within #{@range} km"
      @show_table = true
    else
      @search_result_heading = "No results"
      @show_table = false
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Used for setting user id instance variable for params
  def set_user_id
    @user_id = current_user["id"]
  end

  # Redirects user to profile creation page if no profile for user exists
  def set_user_profile
    if User.find(current_user["id"]).profile == nil
      redirect_to new_profile_path
    else
      @profile = Profile.find(current_user["id"])
    end
  end

  # Build blocklist to prevent users being seen by current_user
  def set_block_lists
    @blocked_list = Blocklist.where(user_id: current_user.id).to_a.pluck(:blocked_id)
    @blocked_by_list = Blocklist.where(blocked_id: current_user.id).to_a.pluck(:user_id)
  end

  def list_hugs
    @hugtype_list = Huglist.all
  end

  def profile_coords(profile)
    return [profile.latitude, profile.longitude]
  end

  def profile_distance
    @distance = "#{current_user.profile.distance_to([@profile.latitude, @profile.longitude]).round(1)} km"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find(params[:id])
  end

  # Search functions
  # Returns hugs of 0: nominated profile , 1: userhugs (profile, huglist_id) that match hugs in '0'
  def find_hug_matches(profile_id)
    # Find hugs of a nominated profile
    profile_hugs = Profile.find(profile_id).huglists.pluck(:huglist_id)
    # Return an array of userhugs that match the nominated profile
    other_hugs = Userhug.where(huglist_id: profile_hugs).where.not(profile_id: current_user.profile.id).where.not(profile_id: @blocked_list).all.pluck(:profile_id, :huglist_id)
    return [profile_hugs, other_hugs]
  end

  def group_hugs(other_hugs)
    profile_list = {}
    other_hugs.each do |id, hug|
      # Checks if profile is already a key
      if profile_list.key?(id)
        # if true, adds hug to array
        profile_list[id].push(hug)
      else
        # if false, creates new key with hug in array as value
        profile_list[id] = [hug]
      end
    end
    profile_list
    return profile_list
  end

  # returns array of pairs (profile_id, hug score) sorted by scores desc
  def hug_score_sort(group_hugs)
    scoring = []
    group_hugs.each do |profile, huglist|
      scoring.push([profile, huglist.count])
    end
    scoring = scoring.sort_by { |profile, score| score }
    return scoring.reverse
  end

  def profile_results(hug_score_sort)
    # Determine profiles and order
    profile_ids_required = []
    hug_score_sort.each do |profile, score|
      profile_ids_required.push(profile)
    end
    # Retrieve profiles
    profile_data = Profile.where(id: profile_ids_required)
    # Shuffle profiles into order by score
    profiles_sorted = []
    profile_ids_required.each do |order_id|
      profile_data.each do |profile|
        if order_id == profile[:id]
          profiles_sorted.push(profile)
        end
      end
    end
    puts "profiles_sorted :"
    p profiles_sorted
    return profiles_sorted
  end

  # Changes matched hugs from hugtype_ids to hugtypes
  def verbose_hugs(matched_hugs)
    huglist_ref = Huglist.all.pluck(:id, :hugtype)
    output = {}
    matched_hugs.each_pair { |profile, hugs|
      hug_names = []
      for hug in hugs
        for hugtype in huglist_ref
          if hugtype[0] == hug
            hug_names.push(hugtype[1])
          end
        end
      end
      output[profile] = hug_names
    }
    return output
  end

  # find all profiles within range of user profile, ordered by distance asc
  def find_near_profile(profile, range)
    # Use Profile.near method provided by Geocoder gem to search for nearest profiles within rang
    results = profile.nearbys(range, units: :km).where.not(user_id: current_user.profile.id).where.not(user_id: @blocked_list)

    # Determine profiles and order
    list = []
    results.each do |result|
      result[:id]
      list.push(result[:id])
    end
    p "'list' : #{list}"

    # Retrieve profiles
    profile_data = Profile.all.where(id: list)
    profiles_sorted = []
    puts "profile_data.each loop..."
    list.each do |order_id|
      profile_data.each do |entry|
        if order_id == entry["id"]
          p entry
          profiles_sorted.push(entry)
        end
      end
    end

    # Debugging server output
    puts ""
    # puts "'profiles_sorted' from 'find_near_profile' : "
    # p profiles_sorted

    return profiles_sorted
  end

  # Only allow a list of trusted parameters through for profile model.
  def profile_params
    params.require(:profile).permit(:user_id, :name_first, :name_second, :name_display, :description, :picture, :street_number, :road, :suburb, :city, :state, :postcode, :country, huglist_ids: [])
  end

  # Only allow a list of trusted parameters through for search
  def search_params
    params.permit(:range, :commit, :utf8)
  end
end
