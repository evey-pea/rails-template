class MessagesController < ApplicationController
  before_action :authenticate_user!

  before_action do
    @conversation = Conversation.find(params[:conversation_id])
    partner_id = (@conversation.sender_id == current_user.id) ? @conversation.receiver_id : @conversation.sender_id
    @conversation_partner = User.find(partner_id).profile
  end
  before_action :set_blocked, only: [:index]

  def index
    @messages = @conversation.messages

    @messages.where("user_id != ? AND read = ?", current_user.id, false).update_all(read: true)

    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_messages_path(@conversation)
    end
  end

  private

  def message_params
    params.require(:message).permit(:body, :user_id)
  end

  def set_blocked
    @blocked = Blocklist.where(blocked_id: current_user.id, user_id: @conversation_partner[:user_id]).present?
    p "User blocked? #{@blocked}"
  end
end
