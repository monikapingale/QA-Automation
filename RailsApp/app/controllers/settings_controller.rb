class SettingsController < ApplicationController
  protect_from_forgery with: :null_session

  # GET /settings
  # GET /settings.json
  def index
    render json: { status: 200, output:Setting.all}
  end
  # GET /settings/1
  # GET /settings/1.json
  #
  def show
    puts "-------------------------------------------------------"
    puts Setting.where(:name => params['id']).select(:name , :value).take.inspect
    render json: { status: 200, output:Setting.where(:name => params['id']).select(:name , :value).take}
  end

  # GET /settings/new
  def new
    @setting = Setting.new
  end

  # GET /settings/1/edit
  def edit
  end

  # POST /settings
  # POST /settings.json
  def create
    @setting = Setting.new(setting_params)
    existsSetting  = Setting.where(:name => @setting.name)
    if existsSetting.empty?
      if @setting.save
        render json: { status: 200, output:Setting.where(name: @setting.name)}
      else
        render json: { status: 500, output:'Error occured while insertion'}
      end
    else
      if existsSetting.update(:name => @setting.name,:value => @setting.value)
        render json: { status: 200, output:Setting.all}
      else
        render json: { status: 500, output:'Update failed'}
      end
    end
  end

  # PATCH/PUT /settings/1
  # PATCH/PUT /settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to @setting, notice: 'Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1
  # DELETE /settings/1.json
  def destroy
    @setting.destroy
    respond_to do |format|
      format.html { redirect_to settings_url, notice: 'Setting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.require(:setting).permit(:name, :value)
    end
end
