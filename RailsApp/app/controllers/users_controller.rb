class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  # GET /users
  # GET /users.json
  def index
    render json: {status: 200, output: User.select(:id, :email, :status, :admin)}
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render json: {status: 200, output: User.where(:id => params['id']).select(:id,:email,:status,:admin).take}
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    user = User.where(:id => params['id'].split('&')[0]).take
    user.update(:status => params['id'].split('&')[1])
    render json: {status: 200, output: user['status']}
  end

  # POST /users
  # POST /users.json
  def create
    user = User.new(user_params)
    user['admin'] = params["type"].eql? 'Admin'
    user['status'] = true
    existingUser = User.where(:email => user['email'])
    if existingUser.empty?
      user.update(:email => user['email'])
      render json: {status: 200, output: User.select(:id,:email,:status,:admin)}
    else
      if existingUser.update(:email => user["email"] , :admin => user['admin'])
        render json: {status: 200, output: User.select(:id,:email,:status,:admin)}
      else
        render json: {status: 500, output: 'Something goes wrong  :( '}
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html {redirect_to @user, notice: 'User was successfully updated.'}
        format.json {render :show, status: :ok, location: @user}
      else
        format.html {render :edit}
        format.json {render json: @user.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if User.where(:id => params['id']).take.destroy
      render json: {status: 200, output: User.select(:id,:email,:status,:admin)}
    else
      render json: {status: 500, output: User.select(:id,:email,:status,:admin)}
    end
  end

  # POST /deactivate

  def deactivate
    user = User.find(params[:user_id])
    user.status = !(user.status)
    if user.update({'id' => user.id})
      @users = User.all
      redirect_to 'http://localhost:3000/app#!/users'
    else
      format.html {render :edit}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :admin)
  end
end
