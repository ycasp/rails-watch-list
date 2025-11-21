# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'open-uri'
require 'json'

Bookmark.destroy_all
Movie.destroy_all
List.destroy_all
puts "all tables deleted"

movie_uri = URI.open("https://tmdb.lewagon.com/movie/top_rated").read
movies = JSON.parse(movie_uri)

list_uri = URI.open("https://tmdb.lewagon.com/genre/movie/list").read
lists = JSON.parse(list_uri)

lists["genres"].each do |list|
  List.create(list)
end
puts "#{List.count} list created, eg #{List.first.name}"

movies["results"].each do |scraped_movie|
  movie = Movie.new
  movie.id = scraped_movie["id"]
  movie.title = scraped_movie["original_title"]
  movie.overview = scraped_movie["overview"]
  movie.rating = scraped_movie["vote_average"].truncate(1)
  movie.poster_url = "https://image.tmdb.org/t/p/w300#{scraped_movie["poster_path"]}"
  movie.save
  scraped_movie["genre_ids"].each do |genre_id|
    Bookmark.create(movie_id: movie.id, list_id: genre_id, comment: "recommended by Axel")
  end
end
puts "#{Movie.count} list created, eg #{Movie.first.title}"
puts "#{Bookmark.count} list created, eg #{Bookmark.first.comment}"
