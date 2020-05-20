class BlocklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :blocklist_params, only: [:create]
  before_action :set_block, only: [:destroy]
  def index
    @blocklist = Blocklist.where(user_id: current_user.id).to_a

    #  = Profile.all.where(user_id: @list)
  end

  def create
    @blocklist = current_user.blocklists.create(blocked_id: blocklist_params)

    respond_to do |format|
        format.html { redirect_to profiles_url, notice: "User was successfully blocked." }
        format.json { head :no_content }
    end
  end

  def destroy
    p @block.destroy
    
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: "Block was successfully removed." }
      format.json { head :no_content }
    end
  end

  private

  def set_block
    @block = Blocklist.find(params[:id])
  end

  def blocklist_params
    params.require(:blocked_id)#.permit(:blocked_id)
  end
end
