class UserFilesController < ApplicationController
  # GET /user_files
  # GET /user_files.json
  def index
    authorize! :read, UserFile
    @user_files = UserFile.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @user_files }
    end
  end

  # GET /user_files/1
  def show 
    @user_file = UserFile.find(params[:id])
    authorize! :read, @user_file
    if @user_file
      send_file @user_file.uploaded_file.path, :type=> @user_file.uploaded_file_content_type 
    end
  end

  # GET /user_files/new
  # GET /user_files/new.json
  def new
    @user_file = UserFile.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user_file }
    end
  end

  # GET /user_files/1/edit
  def edit
    @user_file = UserFile.find(params[:id])
  end

  # POST /user_files
  # POST /user_files.json
  def create
    @user_file = UserFile.new(params[:user_file])

    respond_to do |format|
      if @user_file.save
        format.html { redirect_to @user_file, :notice => 'User file was successfully created.' }
        format.json { render :json => @user_file, :status => :created, :location => @user_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_files/1
  # PUT /user_files/1.json
  def update
    @user_file = UserFile.find(params[:id])
    authorize! :update, @user_file
    respond_to do |format|
      if @user_file.update_attributes(params[:user_file])
        format.html { redirect_to @user_file, :notice => 'User file was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_files/1
  # DELETE /user_files/1.json
  def destroy
  
    @user_file = UserFile.find(params[:id])
    authorize! :destroy, @user_file
    name=@user_file.uploaded_file_file_name
    @user_file.destroy

    respond_to do |format|
      format.html { redirect_to :back,:notice=>"Deleted file: "+name }
      format.json { head :ok }
    end
  end
end
