class WebReservationsController < ApplicationController
  before_action :set_web_reservation, only: [:show, :edit, :update, :destroy, :determination]

  def index
    # 管理予約と紐づかないもののみ
    @web_reservations = WebReservation.has_not_mng.where('web_reservations.number > 0').order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @web_reservation.update(web_reservation_params)
      redirect_to web_reservations_url, notice: 'WEB予約を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    # 数量を0にする
    @web_reservation.update(number: 0)
    redirect_to web_reservations_url, notice: 'WEB予約を削除しました。'
  end

  # ※MNG予約登録
  def determination
    if create_mng_reservation_from_web_reservation(@web_reservation)
      redirect_to web_reservations_url, notice: 'WEB予約をMNG予約に登録しました。'
    else
      redirect_to web_reservations_url, notice: '登録できませんでした。'
    end
  end

  private
    def set_web_reservation
      # 管理予約と紐づかないもののみ
      @web_reservation = WebReservation.has_not_mng.find(params[:id])
    end
    def web_reservation_params
      params.require(:web_reservation).permit(:user_name, :item_id, :number, :start_date, :end_date)
    end
end
