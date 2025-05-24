# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionFix
  respond_to :json

  before_action :authenticate_user!, only: [:destroy]

  private

  def respond_with(resource, _opts = {})
    render json: {message: 'Logged in successfully.', data: resource}, status: :ok
  end

  def respond_to_on_destroy
      render json: { message: 'Logged out successfully'}, status: :ok
  end
end
