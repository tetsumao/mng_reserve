class StaffsController < ApplicationController
  before_action :set_staff, only: [:show, :edit, :update, :destroy]

  def index
    @staffs = Staff.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @staff = Staff.new
  end

  def edit
  end

  def create
    @staff = Staff.new(staff_params)

    if @staff.save
      redirect_to staffs_url, notice: '職員を作成しました。'
    else
      render :new
    end
  end

  def update
    if @staff.update(staff_params)
      redirect_to staffs_url, notice: '職員を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @staff.destroy
    redirect_to staffs_url, notice: '職員を削除しました。'
  end

  private
    def set_staff
      @staff = Staff.find(params[:id])
    end
    def staff_params
      params.require(:staff).permit(:login_name, :password, :staff_name, :dspo)
    end
end
