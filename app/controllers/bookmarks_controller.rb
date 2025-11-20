class BookmarksController < ApplicationController
  before_action :set_list, only: [ :create, :new ]
  before_action :set_movie_titles, only: [ :create, :new ]

  def new
    @bookmark = Bookmark.new
  end

  def create
    @bookmark = Bookmark.new(comment: bookmark_params[:comment])
    @bookmark.movie_id = Movie.find_by(title: bookmark_params[:movie_id]).id
    @bookmark.list_id = @list.id
    if @bookmark.save
      redirect_to list_path(@list.id)
    else
      render :new, status: :unprocessable_content, notice: @bookmark.errors[:movie_id].first
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    list_id = @bookmark.list_id
    @bookmark.destroy
    redirect_to list_path(list_id)
  end

  private

  def bookmark_params
    return params.require(:bookmark).permit(:comment, :movie_id)
  end

  def set_list
    @list = List.find(params[:list_id])
  end

  def set_movie_titles
    @movie_titles = Movie.select(:title).map { |movie| movie.title }
  end
end
