class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy, :change]
  respond_to :html
  respond_to :js
  # GET /tasks
  # GET /tasks.json
  def index
    if params.has_key? (:tag_name)
      @open_due   = current_user.tasks.where(state: "Open").tagged_with(params[:tag_name]).order(:due).select{|task| !task['due'].nil?}
      @open_nodue = current_user.tasks.where(state: "Open").tagged_with(params[:tag_name]).select{|task| task['due'].nil?}
    elsif params.has_key? (:done)
      @open_due   = current_user.tasks.where(state: "done").order(:due).select{|task| !task['due'].nil?}
      @open_nodue = current_user.tasks.where(state: "done").select{|task| task['due'].nil?}
    else 
      @open_due   = current_user.tasks.where(state: "Open").order(:due).select{|task| !task['due'].nil?}
      @open_nodue = current_user.tasks.where(state: "Open").select{|task| task['due'].nil?}
    end
    @tag_counts = ActsAsTaggableOn::Tag.joins(:taggings).where(taggings: { taggable_type: "Task", taggable_id: current_user.task_ids }).group("tags.id").count
    @tags = ActsAsTaggableOn::Tag.all
   end
  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  def change  
    @task.update_attributes(state: params[:state])
    respond_to do |format| 
      format.html { redirect_to tasks_path, notice: "Task updated"}
    end
  end  

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = current_user.tasks.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to(:back) }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to root_path, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:content, :state, :tag_list, :due)
    end
end
