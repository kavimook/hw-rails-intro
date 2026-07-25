class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
    
    # Boolean flag to track if we need to redirect
    redirect_needed = false

    # 1. Handle Sorting
    if params[:sort]
      session[:sort] = params[:sort]
    elsif session[:sort]
      redirect_needed = true
    end

    # 2. Handle Ratings
    if params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      redirect_needed = true
    end

    # 3. Redirect if URL is missing the session parameters
    if redirect_needed
      flash.keep
      redirect_to movies_path(sort: session[:sort], ratings: session[:ratings])
      return # Make sure to return so the rest of the controller doesn't execute
    end

    # 4. Set up your instance variables for the view using session values
    @sort = session[:sort]
    @ratings_to_show_hash = session[:ratings] || Hash[@all_ratings.map { |r| [r, 1] }]
    
    # 5. Fetch movies from DB using @sort and @ratings_to_show_hash.keys
    @movies = Movie.with_ratings(@ratings_to_show_hash.keys).order(@sort)
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
