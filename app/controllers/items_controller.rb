class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = Item.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to items_url, notice: 'アイテムを作成しました。'
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to items_url, notice: 'アイテムを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to items_url, notice: 'アイテムを削除しました。'
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:item_name, :stock, :description, :dspo)
    end
end
