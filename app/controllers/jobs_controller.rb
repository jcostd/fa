class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs
  def index
    base_query = Job.includes(:location)

    @jobs = case params[:filter]
    when "future"
              base_query.where("date >= ?", Date.current).order(date: :asc)
    when "unassigned"
              base_query.where.missing(:photographer_participations).order(date: :desc)
    else
              base_query.recent
    end

    @pagy, @jobs = pagy(@jobs)
  end

  # GET /jobs/1
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
    assign_morph_params
  end

  # GET /jobs/1/edit
  def edit
    assign_morph_params
  end

  # POST /jobs
  def create
    @job = Job.new(job_params)

    if @job.save
      redirect_to jobs_path, notice: "Lavoro creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/1
  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Lavoro aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Lavoro eliminato definitivamente."
  end

  private
    def set_job
      @job = Job.find(params[:id])
    end

    def assign_morph_params
      @job.location_id = params[:new_location_id] if params[:new_location_id].present?
      @job.photographer_id = params[:new_photographer_id] if params[:new_photographer_id].present?
      @job.client_id = params[:new_client_id] if params[:new_client_id].present?
    end

    def job_params
      params.require(:job).permit(
        :date, :start_at, :end_at, :description, :notes, :with_video, :location_id,

        # legacy
        :from_time, :to_time, :legacy_location
      )
    end
end
