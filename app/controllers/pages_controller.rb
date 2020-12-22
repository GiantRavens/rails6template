class PagesController < ApplicationController

  before_action :authenticate_user!, except: %i[index about]

  def index
  end

  def welcome
  end

  def about
  end
end
