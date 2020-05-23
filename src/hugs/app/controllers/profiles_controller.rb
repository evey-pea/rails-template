class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_profile, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_user_id, only: [:new, :edit]
  before_action :set_profile, only: [:show]
  before_action :profile_distance, only: [:show]
  before_action :set_block_lists, only: [:index]

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
    profile = profile_params[:profile]
    puts params[:huglist_id]
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
    p @blocked_list = Blocklist.where(user_id: current_user.id).to_a.pluck(:blocked_id)
    p @blocked_by_list = Blocklist.where(blocked_id: current_user.id).to_a.pluck(:user_id)
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

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(:user_id, :name_first, :name_second, :name_display, :description, :picture, :street_number, :road, :suburb, :city, :state, :postcode, :country, :huglist_ids)
  end
end
