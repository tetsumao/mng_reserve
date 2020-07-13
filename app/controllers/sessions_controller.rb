class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
    if current_staff
      redirect_to :root
    else
      @form = LoginForm.new
      render action: 'new'
    end
  end

  def create
    @form = LoginForm.new(login_form_params)
    if @form.login_name.present?
      staff = Staff.find_by(login_name: @form.login_name)
    end
    if Authenticator.new(staff).authenticate(@form.password)
      session[:staff_id] = staff.id
      session[:staff_last_access_time] = Time.current
      flash.notice = 'ログインしました。'
      redirect_to :root
    else
      flash.now.alert = 'メールアドレスまたはパスワードが正しくありません。'
      render action: 'new'
    end
  end

  def destroy
    session.delete(:staff_id)
    flash.notice = 'ログアウトしました。'
    redirect_to :root
  end

  private
  
  def login_form_params
    params.require(:login_form).permit(:login_name, :password)
  end
end
