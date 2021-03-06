class BookingsController < ApplicationController
  before_action :set_booking, only: %i[ show edit update destroy ]
  # before_action :authuser, only: [ :index, :edit, :destroy ]  

  # GET /bookings or /bookings.json
  def index
    @bookings = Booking.all
  end

  # GET /bookings/1 or /bookings/1.json
  def show
    @timeslot = Timeslot.find_by_id(@booking.timeslot_id)
    @timeslot.status = "true"
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
    @table = Table.find(params[:table_id])
    @user = User.find(params[:user_id])

    @timeslot = Timeslot.where(:table_id => params[:table_id])
  end

  # GET /bookings/1/edit
  def edit
  end

  # u.bookings << t
  # POST /bookings or /bookings.json
  def create
    # @table = Table.find(params[:table_id])
    # @user = User.find(params[:user_id])
    @booking = Booking.new(booking_params)
    # @booking.table_id = @table.id
    @booking.user_id = current_user.id
    # @table = @bookings.table.build(params[:table_id])
    # user.bookings.create(table)

    # @timeslot = Timeslot.find(params[:timeslot_id])
    # @timeslot.status = true
    respond_to do |format|
      if @booking.save
        # BookingMailerJob.perform_later
        BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_mail.deliver_later
        BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_rest_mail.deliver_later
        # BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_mail.deliver_later
        # BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_rest_mail.deliver_later
        format.html { redirect_to @booking, notice: "Booking was successfully created." }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_mail.deliver_later
        BookingMailer.with(booking: @booking, restaurant: @booking.table.restaurant_mail).new_booking_rest_mail.deliver_later
        format.html { redirect_to @booking, notice: "Booking was successfully updated." }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url, notice: "Booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def cancel
    @booking = Booking.find(params[:id])
    respond_to do |format|
      if @booking.update(cancel: true, status: false)
        format.html { redirect_to profile_path, notice: "Booking was cancelled successfully." }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:user_id, :table_id, :name, :email, :phone_no, :notes, :date, :timeslot_id)
    end

    def authuser
      unless current_user.role == 'admin'
        redirect_to root_path
      end
    end

end
