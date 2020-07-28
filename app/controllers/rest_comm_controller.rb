class RestCommController < ApplicationController
  def req
    # WebReservationLinkage クラスに責務を分けた
    client = WebReservationLinkage.new

    # url_base = "#{ENV['WEB_RESERVE_URL']}/api/"
    # options = { content_type: :json, accept: :json }

    # APIでログイン

    # response = RestClient.post("#{url_base}sign_in.json", {login_name: ENV['API_LOGIN_NAME'], password: ENV['API_PASSWORD']}, options)
    # login = JSON.parse(response.body)
    # options[:Authorization] = "Bearer #{login['token']}"

    # 現在の日時

    time_now = Time.current
    # Time.zone.now
    # 本日
    # date = Date.new(time_now.year, time_now.month, time_now.day)


    #------------------------- マスタ更新 -------------------------
    client.send_master

    # MEMO: response を使い回さないようにしたい

    # response = RestClient.get("#{url_base}master_updated_at.json", options)
    # puts "response #{response.body}"
    # master_updated_at = JSON.parse(response.body)

    # master = Item.web_master(master_updated_at['items'])
    # if master.length > 0
    #   RestClient.post("#{url_base}upsert_items.json", {items: master.to_json}, options)
    # end

    #------------------------- MNG予約更新(WEB非連携) -------------------------
    # MNG予約リスト[id, updated_at]を取得
    response = RestClient.get("#{url_base}mng_reservation_id_updated_at.json?date=#{time_now.to_date}", options)
    mng_reservation_id_updated_at = JSON.parse(response.body)
    # {id: updated_at}の形
    mng_i_u = mng_reservation_id_updated_at['mng_reservations']
    puts "mng_i_u #{mng_i_u}"
    h_mngs = []
    # MNG予約テーブルを取得
    # 日時の最小(比較用)
    time_min = Time.new(2000, 1, 1, 0, 0, 0)
    MngReservation.belongs_not_web.where('mng_reservations.end_date >= ?', time_now.to_date).each do |mng_reservation|
      mng_reservation_id_s = mng_reservation.id.to_s
      # 対象IDがあるかどうか
      if mng_i_u.key?(mng_reservation_id_s)
        # 同じ時間でも>が真になるので0.1秒進める
        updated_at = Time.zone.parse(mng_i_u.delete(mng_reservation_id_s)) + 0.1
      else
        updated_at = time_min
      end
      puts "mng_reservation_id #{mng_reservation_id_s} #{mng_reservation.updated_at} > #{updated_at} ?"
      # 更新があるものを取り込み
      if mng_reservation.updated_at > updated_at
        h_mngs << {
          id: mng_reservation.id,
          user_name: mng_reservation.user_name,
          item_id: mng_reservation.item_id,
          number: mng_reservation.number,
          reservation_name: mng_reservation.reservation_name,
          reservation_date: mng_reservation.reservation_date,
          start_date: mng_reservation.start_date,
          end_date: mng_reservation.end_date,
          web_reservation_id: mng_reservation.web_reservation_id,
          created_at: mng_reservation.created_at,
          updated_at: mng_reservation.updated_at
        }
      end
    end
    # 新規or更新
    if h_mngs.present?
      RestClient.post("#{url_base}upsert_mng_reservations.json", {mng_reservations: h_mngs.to_json}, options)
    end
    # {id: updated_at}が残っていたら削除
    if mng_i_u.present?
      RestClient.post("#{url_base}destroy_mng_reservations.json", {ids: mng_i_u.keys}, options)
    end

    #------------------------- WEB予約更新 -------------------------
    # WEB側で新規登録されたWEB予約IDリストを先に取得しておく
    response = RestClient.get("#{url_base}web_reservation_ids.json", options)
    web_reservation_ids = JSON.parse(response.body)['ids']
    puts "web_reservation_ids #{web_reservation_ids}"

    @send_mng = 0
    @reseive_web = 0

    # MNG側で前回の送信から更新があったものを取得
    WebReservation.where('updated_at > sent_at').each do |web_reservation|
      # ここで更新するならIDリストからは除外
      web_reservation_ids.delete(web_reservation.id.to_i)
      puts "web_reservation_ids #{web_reservation_ids} without #{web_reservation.id}"
      # WEB予約を送信
      if send_web_reservation(web_reservation, time_now, url_base, options)
        @send_mng += 1
      end
    end
    # すでにWEB予約情報が作成済みのものはidsから除外
    WebReservation.where(id: web_reservation_ids).select(:id).pluck(:id).each do |id|
      puts "web_reservation_ids #{web_reservation_ids} without #{id}"
      web_reservation_ids.delete(id.to_i)
    end

    # WEB側の予約情報を１つ１つ取得しながら新規登録
    web_reservation_ids.each do |id|
      @reseive_web += 1
      # WEB予約情報を取得
      response = RestClient.get("#{url_base}web_reservation.json?id=#{id}", options)
      h_web = JSON.parse(response.body)['web_reservation']
      user = h_web.delete('user')
      # 仮でWEB予約情報に起こす
      web_reservation = WebReservation.new(h_web)
      web_reservation.user_name = user['user_name']
      web_reservation.sent_at = time_min

      # WEB予約情報からMNG予約情報を生成する
      if create_mng_reservation_from_web_reservation(web_reservation)
        # 成功したらWEB予約を送信
        if send_web_reservation(web_reservation, web_reservation.updated_at, url_base, options)
          @send_mng += 1
        end
      else
        # 失敗の場合は保留予約としてWEB予約情報を保存
        web_reservation.save!
      end
    end

    #------------------------- 終了 -------------------------
    # ログアウト
    RestClient.delete("#{url_base}sign_out.json", options)

    # Ajax呼び出しのみ有効
    respond_to do |format|
      format.js
    end
  end

  private
    def send_web_reservation(web_reservation, time_now, url_base, options)
      # MNG予約情報
      mng_reservation = web_reservation.mng_reservation
      if mng_reservation.present?
        h_mng = {
          id: mng_reservation.id,
          user_name: mng_reservation.user_name,
          item_id: mng_reservation.item_id,
          number: mng_reservation.number,
          reservation_name: mng_reservation.reservation_name,
          reservation_date: mng_reservation.reservation_date,
          start_date: mng_reservation.start_date,
          end_date: mng_reservation.end_date,
          web_reservation_id: web_reservation.id,
          created_at: mng_reservation.created_at,
          updated_at: mng_reservation.updated_at
        }
      end
      # WEB予約情報
      h_web = {
        id: web_reservation.id,
        item_id: web_reservation.item_id,
        number: web_reservation.number,
        start_date: web_reservation.start_date,
        end_date: web_reservation.end_date,
        updated_at: web_reservation.updated_at
      }
      h_web[:mng_reservation] = h_mng if h_mng.present?

      # WEB側へ更新通知
      response = RestClient.post("#{url_base}update_web_reservation.json", {web_reservation: h_web.to_json}, options)
      success = JSON.parse(response.body)['success']
      if success == true
        # 更新通知できたら時間を更新(updated_atを更新しない)
        web_reservation.record_timestamps = false
        web_reservation.update(sent_at: time_now)
        web_reservation.record_timestamps = true
      end
      success
    end
end
