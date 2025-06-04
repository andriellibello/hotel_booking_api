class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def create 
    room = Room.find_by(id: params[:room_id])
    return render json: {error: "Quarto não encontrado"}, status: :not_found unless room

    start_date = Date.parse(params[:start_date])
    end_date= Date.parse(params[:end_date])
    adults = params[:adults].to_i
    children = params[:children].to_i
    total_people = adults + children

    if start_date >= end_date
      return render json: { error: "Data de saída deve ser maior que a data de entrada"}, status: :unprocessable_entity
    end

    if total_people > room.capacity 
      return render json: { error: "Número de pessoas excede a capacidade do quarto" }, status: :unprocessable_entity
    end

    if room_unavailable?(room, start_date, end_date)
      return render json: { error: "Quarto indisponível para as datas selecionadas" }, status: :unprocessable_entity
    end

    num_nights = (end_date - start_date).to_i
    total_price = room.price * num_nights

    reservation = Reservation.new(
      user: current_user,
      room: room,
      start_date: start_date,
      end_date: end_date,
      total_price: total_price,
      status: "confirmada"
    )

    if reservation.save
      render json: reservation.as_json(only: [:id, :room_id, :start_date, :end_date, :total_price, :status]), status: :created
    else
      render json: { error: reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    reservations  = current_user.reservations.includes(:room)

    render json: reservations.map { |reservation|
      {
        id: reservation.id,
        start_date: reservation.start_date,
        end_date: reservation.end_date,
        total_price: reservation.total_price,
        status: reservation.status,
        room: {
          number: reservation.room.number,
          description: reservation.room.description,
          capacity: reservation.room.capacity,
          price: reservation.room.price
        }
      }
    }
  end

  
  def cancel
    reservation = Reservation.find_by(id: params[:id])

    return render json: {error: "Reserva não encontrada"}, status: :not_found unless reservation

    unless reservation.user_id == current_user.id
      return render json: { error: "Você não tem permissão para cancelar esta reserva" }, status: :forbidden
    end
  
    reservation.status = "cancelada"

    if reservation.save 
      render json: reservation.as_json(only: [:id, :room_id, :start_date, :end_date, :total_price, :status])
    else
       render json: { error: reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 

  def room_unavailable?(room, start_date, end_date)
    Reservation.where(room: room, status: "confirmada")
               .where("start_date < ? AND end_date > ?", end_date, start_date)
               .exists?
  end
end
