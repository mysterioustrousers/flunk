class BananasController < ApplicationController
  # GET /bananas
  # GET /bananas.json
  def index
    @bananas = Banana.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bananas }
    end
  end

  # GET /bananas/1
  # GET /bananas/1.json
  def show
    @banana = Banana.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @banana }
    end
  end

  # GET /bananas/new
  # GET /bananas/new.json
  def new
    @banana = Banana.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @banana }
    end
  end

  # GET /bananas/1/edit
  def edit
    @banana = Banana.find(params[:id])
  end

  # POST /bananas
  # POST /bananas.json
  def create
    @banana = Banana.new(params[:banana])

    respond_to do |format|
      if @banana.save
        format.html { redirect_to @banana, notice: 'Banana was successfully created.' }
        format.json { render json: @banana, status: :created, location: @banana }
      else
        format.html { render action: "new" }
        format.json { render json: @banana.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bananas/1
  # PUT /bananas/1.json
  def update
    @banana = Banana.find(params[:id])

    respond_to do |format|
      if @banana.update_attributes(params[:banana])
        format.html { redirect_to @banana, notice: 'Banana was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @banana.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bananas/1
  # DELETE /bananas/1.json
  def destroy
    @banana = Banana.find(params[:id])
    @banana.destroy

    respond_to do |format|
      format.html { redirect_to bananas_url }
      format.json { head :no_content }
    end
  end
end
