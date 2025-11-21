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
require 'pry-byebug'

Bookmark.destroy_all
Movie.destroy_all
List.destroy_all
puts "all tables deleted"

movie_uri = URI.open("https://tmdb.lewagon.com/movie/top_rated").read
movies = JSON.parse(movie_uri)

list_uri = URI.open("https://tmdb.lewagon.com/genre/movie/list").read
lists = JSON.parse(list_uri)

list_backgrounds = []
urls = [
  "https://t3.ftcdn.net/jpg/12/65/97/96/360_F_1265979653_4dWWYR8M5bBZI8fqg6fxPcq9pkLBIO6q.jpg",
  "https://res.cloudinary.com/sagacity/image/upload/c_crop,h_2563,w_3840,x_0,y_749/c_limit,dpr_auto,f_auto,fl_lossy,q_80,w_1200/shutterstock_By_Bill45_1201748011_wp6ro2.jpg",
  "https://media.istockphoto.com/id/1492685467/vector/halloween-grave-background.jpg?s=612x612&w=0&k=20&c=ug0HfzbIn0K-07SBZObweUcf2TYxCf6LkMuXLwy4bhI="
]
files = urls.map { |url| URI.parse(url).open}

lists["genres"].each do |list|
  list = List.new(name: list["name"])
  list.photo.attach(io: files.sample, filename: "background.jpg", content_type: "image/jpg")
  list.save
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
    ref_list = lists["genres"].find { |list| list["id"] == genre_id }
    list_id = List.find_by(name: ref_list["name"]).id
    Bookmark.create(movie_id: movie.id, list_id: list_id, comment: "recommended by Axel")
  end
end
puts "#{Movie.count} movie created, eg #{Movie.first.title}"
puts "#{Bookmark.count} bookmarks created, eg #{Bookmark.first.comment}"
