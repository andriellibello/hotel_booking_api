class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:available]
  def index
    rooms = Room.all
    render json: rooms.as_json(only: [:id, :number, :description, :capacity, :price])
  end

  def show
    room = Room.find(params[:id])
    render json: room.as_json(only: [:id, :number, :description, :capacity, :price])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Room not found" }, status: :not_found
  end

  def available
    start_date = Date.parse(params[:start_date]) rescue nil
    end_date = Date.parse(params[:end_date]) rescue nil
    adults = params[:adults].to_i
    children = params[:children].to_i
    total_people = adults + children

    if start_date.nil? || end_date.nil? || start_date >= end_date
      return render json: { error: "Datas inválidas" }, status: :unprocessable_entity
    end

    rooms = Room.where("capacity >= ?", total_people)

    unavailable_room_ids = Reservation 
      .where(status: "confirmada")
      .where("start_date < ? AND end_date > ?", end_date, start_date)
      .pluck(:room_id)

    available_rooms = rooms.where.not(id: unavailable_room_ids)

    render json: available_rooms.as_json(only: [:id, :name, :capacity, :price, :description])
  end
  
end
