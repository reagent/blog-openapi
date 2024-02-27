json.total @posts.count

json.posts do
  json.partial! "post", collection: @posts, as: :post
end
