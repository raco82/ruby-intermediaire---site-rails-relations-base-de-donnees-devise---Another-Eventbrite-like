class EventsController < ApplicationController
  before_action :set_event, only: %i[show register]
  before_action :logged_in_user, only: %i[index new show]

  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      flash[:success] = "New event: #{@event.title} published ! "
      redirect_to event_path(@event)
    else
      flash.now[:danger] = @event.errors.full_messages.to_sentence
      render 'new'
   end
  end

  def show; end

  def register
    @user_id = User.find(params[:user_id])
    @registration = @event.registrations.new
    @registration.user_id = @user_id.id
    if @registration.save
      redirect_to event_path(@event)
    else
      flash[:danger] = "You already invited #{@user_id.username}"
      redirect_to event_path(@event)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.permit(:title, :location, :user_id, :start_date, :end_date)
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'You need to register and login first !'
      redirect_to root_path
    end
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
