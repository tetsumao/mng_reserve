class MngReservationsController < ApplicationController
  before_action :set_mng_reservation, only: [:show, :edit, :update, :destroy]

  def index
    @mng_reservations = MngReservation.where('number > 0').order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def status
    date_from = params[:date_from]
    @date_from = date_from.present? ? Date.parse(date_from) : Date.today
    @date_to = @date_from + 6
    @items = Item.all
  end

  def new
    @mng_reservation = MngReservation.new
  end

  def edit
  end

  def create
    @mng_reservation = MngReservation.new(mng_reservation_params)

    if @mng_reservation.save
      redirect_to mng_reservations_url, notice: '管理予約を予約しました。'
    else
      render :new
    end
  end

  def update
    if @mng_reservation.update(mng_reservation_params)
      redirect_to mng_reservations_url, notice: '管理予約を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    # WEB予約は数量0にする
    @mng_reservation.web_reservation.update(number: 0) if @mng_reservation.web_reservation.present?
    @mng_reservation.destroy
    redirect_to mng_reservations_url, notice: '管理予約を削除しました。'
  end

  private
    def set_mng_reservation
      @mng_reservation = MngReservation.find(params[:id])
    end
    def mng_reservation_params
      params.require(:mng_reservation).permit(:user_name, :item_id, :number, :start_date, :end_date)
    end
end
