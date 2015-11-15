require "crypt"
require "message_params"

class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?

  def new
    @message = Message.new
  end

  def create
    @message = Message.new message_params

    if @message.save
      render :create
    else
      render :new
    end
  end

  def show
    @crypt = Crypt.find params[:id], key_param
    if @crypt.message.file_contents.nil?
      @crypt.destroy
    end
  rescue CryptError
    raise ActiveRecord::RecordNotFound
  end

  def download
    @crypt = Crypt.find params[:id], key_param
    @crypt.destroy
    send_data(
      @crypt.file_contents,
      type: @crypt.message.file_mime_type,
      filename: @crypt.message.file_name,
    )
  rescue CryptError
    raise ActiveRecord::RecordNotFound
  end

  def json_request?
    request.format.json?
  end

  def id_param
    params.permit(:id)
  end

  def key_param
    params.require(:key)
  end

  def message_params
    MessageParams.generate(params.require(:message).permit(:text, :file))
  end
end
