class PingasController < ApplicationController

  def index
    @user = User.find(session[:user_id])
    if request.remote_ip == '127.0.0.1'
      @user.ip_address = '74.122.9.196'
    else
      @user.ip_address = request.remote_ip
    end
    @user.geocode
    @user.update_user_pingas
    @user_marker = @user.marker
    @pinga_markers = pinga_markers
    @pingas_by_received_time = @user.pingas_ordered_by_received_in_listening_radius
    @pingas_by_distance = @user.pingas_ordered_by_distance_in_listening_radius
    @pingas_by_start_time = @user.pingas_ordered_by_start_time_in_listening_radius
    @categories = Category.all
    @pinga = Pinga.new
  end

  def show
    render :json => { show: render_to_string(partial: "pingas/show", locals: { pinga: Pinga.find(params[:id].to_i) }) }
  end

  def destroy
    @pinga = Pinga.find(params[:id])
    @pinga.status = "cancelled"
    if @pinga.save
      render :json => params[:id]
    else
      render :json => false
    end
  end

  private
  
  def pinga_params
    params.require(:pinga).permit(:title, :description, :start_time, :duration, :address, :category_id)
  end
end


def pinga_markers
  pingas = []
  @user.pingas_in_listening_radius.each do |pinga|
    if pinga.status != "expired" && pinga.status != "cancelled"
      marker = { :id         => pinga.id,
                 :latitude   => pinga.latitude,
                 :longitude  => pinga.longitude,
                 :category   => pinga.category.title,
                 :infowindow => render_to_string(:partial => "/shared/infowindow", :locals => { pinga: pinga }),
                 :picture => {  "url" => "#{pinga.category.title}_#{pinga.status}.png",
                                "width" => 20,
                                "height" => 34}
      }
      pingas.push(marker)
    end

  end
  @user.pingas_outside_listening_radius.each do |pinga|
    if pinga.status != "expired" && pinga.status != "cancelled"
      marker = { :id         => pinga.id,
                 :latitude   => pinga.latitude,
                 :longitude  => pinga.longitude,
                 :category   => pinga.category.title,
                 :infowindow => render_to_string(:partial => "/shared/infowindow", :locals => { pinga: pinga }),
                 :picture => {  "url" => "#{pinga.category.title}_outside.png",
                                "width" => 20,
                                "height" => 34}
      }
      pingas.push(marker)
    end
  end
  pingas
end