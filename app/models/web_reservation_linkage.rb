class WebReservationLinkage
  BASE_URL = "#{ENV['WEB_RESERVE_URL']}/api/"
  DEFAULT_OPTIONS = { content_type: :json, accept: :json }
  TIME_MIN = Time.new(2000, 1, 1, 0, 0, 0)

  attr_reader :send_mng, :reseive_web

  def initialize
    response = RestClient.post("#{BASE_URL}sign_in.json", {login_name: ENV['API_LOGIN_NAME'], password: ENV['API_PASSWORD']}, DEFAULT_OPTIONS)
    login = JSON.parse(response.body)
    @options = DEFAULT_OPTIONS.merge(Authorization: "Bearer #{login['token']}")
    @time_now = Time.current
    @send_mng = 0
    @reseive_web = 0
  end

  def send_master
    master_updated_at = get_api('master_updated_at.json')
    master = Item.web_master(master_updated_at['items'])
    if master.length > 0
      post_api('upsert_items.json', {items: master.to_json})
    end
  end

  def send_mng_reservation
    # MNG予約リスト[id, updated_at]を取得
    mng_reservation_id_updated_at = get_api("mng_reservation_id_updated_at.json?date=#{@time_now.to_date}")
    # {id: updated_at}の形
    mng_i_u = mng_reservation_id_updated_at['mng_reservations']
    puts "mng_i_u #{mng_i_u}"
    h_mngs = []
    # MNG予約テーブルを取得
    MngReservation.belongs_not_web.where('mng_reservations.end_date >= ?', @time_now.to_date).each do |mng_reservation|
      mng_reservation_id_s = mng_reservation.id.to_s
      # 対象IDがあるかどうか
      if mng_i_u.key?(mng_reservation_id_s)
        # 同じ時間でも>が真になるので0.1秒進める
        updated_at = Time.zone.parse(mng_i_u.delete(mng_reservation_id_s)) + 0.1
      else
        updated_at = TIME_MIN
      end
      puts "mng_reservation_id #{mng_reservation_id_s} #{mng_reservation.updated_at} > #{updated_at} ?"
      # 更新があるものを取り込み
      if mng_reservation.updated_at > updated_at
        h_mngs << mng_reservation.attributes.symbolize_keys.slice(:id, :user_name, :item_id, :number,
          :reservation_name, :reservation_date, :start_date, :end_date, :web_reservation_id,
          :created_at, :updated_at)
      end
    end
    # 新規or更新
    if h_mngs.present?
      @send_mng += h_mngs.length
      post_api('upsert_mng_reservations.json', {mng_reservations: h_mngs.to_json})
    end
    # {id: updated_at}が残っていたら削除
    if mng_i_u.present?
      @send_mng += mng_i_u.length
      post_api('destroy_mng_reservations.json', {ids: mng_i_u.keys})
    end
  end

  def update_send_web_reservation
    # WEB側で新規登録されたWEB予約IDリストを先に取得しておく
    web_reservation_ids = get_api('web_reservation_ids.json')['ids']
    puts "web_reservation_ids #{web_reservation_ids}"

    # MNG側で前回の送信から更新があったものを取得
    WebReservation.where('updated_at > sent_at').each do |web_reservation|
      # ここで更新するならIDリストからは除外
      web_reservation_ids.delete(web_reservation.id.to_i)
      puts "web_reservation_ids #{web_reservation_ids} without #{web_reservation.id}"
      # WEB予約を送信
      if send_web_reservation(web_reservation, @time_now)
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
      h_web = get_api("web_reservation.json?id=#{id}")['web_reservation']
      user = h_web.delete('user')
      # 仮でWEB予約情報に起こす
      web_reservation = WebReservation.new(h_web)
      web_reservation.user_name = user['user_name']
      web_reservation.sent_at = TIME_MIN

      # WEB予約情報からMNG予約情報を生成する
      if MngReservation.create_from_web_reservation(web_reservation)
        # 成功したらWEB予約を送信
        if send_web_reservation(web_reservation, web_reservation.updated_at)
          @send_mng += 1
        end
      else
        # 失敗の場合は保留予約としてWEB予約情報を保存
        web_reservation.save!
      end
    end
  end

  def logout
    RestClient.delete("#{BASE_URL}sign_out.json", @options)
  end

  private
    def get_api(action)
      puts "get_api #{BASE_URL}#{action}"
      response = RestClient.get("#{BASE_URL}#{action}", @options)
      puts "response #{response.body}"
      JSON.parse(response.body) if response.body.present?
    end

    def post_api(action, data = {})
      response = RestClient.post("#{BASE_URL}#{action}", data, @options)
      puts "response #{response.body}"
      JSON.parse(response.body) if response.body.present?
    end

    def send_web_reservation(web_reservation, sent_at)
      # MNG予約情報
      mng_reservation = web_reservation.mng_reservation
      if mng_reservation.present?
        h_mng = mng_reservation.attributes.symbolize_keys.slice(:id, :user_name, :item_id, :number,
          :reservation_name, :reservation_date, :start_date, :end_date, :web_reservation_id,
          :created_at, :updated_at)
      end
      # WEB予約情報
      puts "web_reservation #{web_reservation.attributes}"
      h_web = web_reservation.attributes.symbolize_keys.slice(:id, :item_id, :number,
        :start_date, :end_date, :updated_at)
      h_web[:mng_reservation] = h_mng if h_mng.present?

      # WEB側へ更新通知
      success = post_api('update_web_reservation.json', {web_reservation: h_web.to_json})['success']
      if success == true
        # 更新通知できたら時間を更新(updated_atを更新しない)
        web_reservation.record_timestamps = false
        web_reservation.update(sent_at: sent_at)
        web_reservation.record_timestamps = true
      end
      success
    end
end
