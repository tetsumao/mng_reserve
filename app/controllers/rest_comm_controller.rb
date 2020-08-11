class RestCommController < ApplicationController
  def req
    # WebReservationLinkage クラスに責務を分けた
    client = WebReservationLinkage.new

    #------------------------- マスタ更新 -------------------------
    client.send_master

    #------------------------- MNG予約更新(WEB非連携) -------------------------
    client.send_mng_reservation

    #------------------------- WEB予約更新 -------------------------
    client.update_send_web_reservation

    #------------------------- 終了 -------------------------
    client.logout

    @send_mng = client.send_mng
    @reseive_web = client.reseive_web

    respond_to do |format|
      format.js
    end
  end
end
