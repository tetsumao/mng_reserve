class ApplicationController < ActionController::Base
  before_action :authorize
  before_action :check_timeout

  helper_method :current_staff
  helper_method :staff_signed_in?

  private
    def current_staff
      if session[:staff_id]
        @current_staff ||= Staff.find_by(id: session[:staff_id])
      end
    end

    def staff_signed_in?
      current_staff.present?
    end

    def authorize
      unless current_staff
        flash.alert = '職員としてログインしてください。'
        redirect_to :login
      end
    end

    def check_timeout
      if current_staff && session[:staff_last_access_time]
        # 60分でセッションタイムアウト
        if session[:staff_last_access_time] >= 60.minutes.ago
          session[:staff_last_access_time] = Time.current
        else
          session.delete(:staff_id)
          flash.alert = 'セッションがタイムアウトしました。'
          redirect_to :login
        end
      end
    end
end
