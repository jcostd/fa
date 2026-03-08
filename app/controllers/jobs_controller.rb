class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs
  def index
    base_query = Job.includes(:locations, participations: :contact)

    @jobs = case params[:filter]
    when "future"
              base_query.where("date >= ?", Date.current).order(date: :asc)
    when "unassigned"
              # Usiamo un left outer join per trovare i job senza fotografi
              base_query.left_outer_joins(:participations)
                .where(participations: { id: nil })
                .or(base_query.left_outer_joins(:participations).where.not(participations: { role: Participation::ROLES[:photographer] }))
                .group("jobs.id")
                .order(date: :desc)
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
  end

  # GET /jobs/1/edit
  def edit
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
      @job = Job.includes(:locations, participations: :contact).find(params[:id])
    end

    def job_params
      params.require(:job).permit(
        :description, :notes, :date, :start_at, :end_at, :with_video,

        # legacy
        :legacy_location_text, :from_time, :to_time,

        # locations
        job_locations_attributes: [ :id, :location_id, :position, :_destroy ],

        # participations
        participations_attributes: [ :id, :contact_id, :role, :title, :_destroy ]
      )
    end
end
