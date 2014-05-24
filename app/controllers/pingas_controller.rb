class PingasController < ApplicationController

  def index
    @user = User.find(session[:user_id])
    @user.geocode
    @user.update_user_pingas
    @user_marker = @user.marker # does there need to be a user.save! here ?
    @pinga_markers = @user.pinga_markers
    @pingas_by_received_time = @user.pingas_ordered_by_received_in_listening_radius
    @pingas_by_distance = @user.pingas_ordered_by_distance_in_listening_radius
    @pingas_by_start_time = @user.pingas_ordered_by_start_time_in_listening_radius
  end

  def show
    @pinga = Pinga.find(params[:id])
    if @pinga.status == "inactive"
      flash[:notice] = "I'm sorry, that pingIt is no longer active!"
      redirect_to root_url
    end
  end

  def new
    @user = User.find(session[:user_id])
    if request.remote_ip == '127.0.0.1'
      @user.latitude = 39.650389 # <- this is Woodstown, NJ; hopefully the map centers here. coords for DBC: 41.8899109
      @user.longitude = -75.324764 # <- Woodstown, NJ; coords for DBC: -87.6376566
    else
      @user.ip_address = request.remote_ip
    end
    @user.save
    @user_marker = @user.marker
    @pinga = Pinga.new
  end

  def create
    valid_start_time = Time.now + 12.hours
    puts "X"*50
    p valid_start_time
    p params
    puts "X"*50
    @user = User.find(session[:user_id])
    @pinga = Pinga.new(title: params["pinga"]["title"])
    @pinga.status = "pending" # this needs to be checked against the start time
    @pinga.description = params["pinga"]["description"]
    @pinga.start_time = params["pinga"]["start_time"]
    @pinga.end_time = params["pinga"]["end_time"]
    @pinga.address = params["pinga"]["address"]
    @pinga.creator = @user

    # if @pinga.start_time < Time.now # earlier than right now
    #   @status = "active"
    # elsif @pinga.start_time 
    # else @pinga.start_time < Time.now
    # end

    if @pinga.save
      redirect_to pinga_path(@pinga)
    else
      render :new
    end
  end

  def destroy
    @pinga = Pinga.find(params[:id])
    @pinga.status = "inactive"
    @pinga.save
    redirect_to root_url
  end
end