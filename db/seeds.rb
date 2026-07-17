# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
#
#
# db/seeds.rb

require "json"
require "open-uri"
require "uri"
require "stringio"

# ------------------------------------------------------------
# IMAGE ATTACHMENT
# ------------------------------------------------------------

def attach_product_image(product, image_url, attempts: 3)
  return if image_url.blank?

  if product.product_images.any? { |record| record.image.attached? }
    puts "  Image already attached."
    return
  end

  uri = URI.parse(image_url)

  downloaded_file = URI.open(
    uri.to_s,
    "User-Agent" =>
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " \
      "AppleWebKit/537.36 Chrome/120.0 Safari/537.36",
    "Accept" => "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
    "Referer" => "https://www.long-mcquade.com/",
    open_timeout: 15,
    read_timeout: 30
  )

  image_data = downloaded_file.read

  if image_data.blank?
    raise "Downloaded image was empty"
  end

  content_type =
    downloaded_file.content_type.presence ||
    content_type_from_filename(uri.path)

  filename = File.basename(uri.path)

  if filename.blank?
    extension = extension_for_content_type(content_type)
    filename = "product-#{product.id}.#{extension}"
  end

  product_image = product.product_images.build(
    alt_text: product.name,
    position: product.product_images.count + 1
  )

  product_image.image.attach(
    io: StringIO.new(image_data),
    filename: filename,
    content_type: content_type,
    identify: false
  )

  product_image.save!

  puts "  Image attached: #{filename}"

  # Slow down requests to the CDN.
  sleep 1
rescue OpenURI::HTTPError,
       Net::OpenTimeout,
       Net::ReadTimeout,
       SocketError,
       Errno::ECONNRESET => error

  if attempts > 1
    wait_time = 4 - attempts

    warn(
      "  Image request failed for #{product.name}: " \
      "#{error.message}. Retrying in #{wait_time} seconds..."
    )

    sleep wait_time

    attach_product_image(
      product,
      image_url,
      attempts: attempts - 1
    )
  else
    warn(
      "  Image failed after 3 attempts for #{product.name}: " \
      "#{error.message}"
    )
  end
rescue URI::InvalidURIError => error
  warn "  Invalid image URL for #{product.name}: #{error.message}"
rescue ActiveRecord::RecordInvalid => error
  warn(
    "  ProductImage validation failed for #{product.name}: " \
    "#{error.record.errors.full_messages.join(", ")}"
  )
rescue StandardError => error
  warn(
    "  Image could not be saved for #{product.name}: " \
    "#{error.class} — #{error.message}"
  )
end

def content_type_from_filename(path)
  case File.extname(path).downcase
  when ".jpg", ".jpeg"
    "image/jpeg"
  when ".png"
    "image/png"
  when ".webp"
    "image/webp"
  when ".gif"
    "image/gif"
  else
    "application/octet-stream"
  end
end

def extension_for_content_type(content_type)
  case content_type
  when "image/jpeg"
    "jpg"
  when "image/png"
    "png"
  when "image/webp"
    "webp"
  when "image/gif"
    "gif"
  else
    "bin"
  end
end

# ------------------------------------------------------------
# JSON FILES
# ------------------------------------------------------------

json_files = [
  {
      path: Rails.root.join(
        "db",
        "data",
        "long_mcquade_lights_fog.json"
      ),
      category: "Lighting Equipment"
    },
    {
      path: Rails.root.join(
        "db",
        "data",
        "long_mcquade_mixers.json"
      ),
      category: "Audio Equipment"
    },
    {
      path: Rails.root.join(
        "db",
        "data",
        "long_mcquade_pa_speakers.json"
      ),
      category: "Audio Equipment"
    }
]

# ------------------------------------------------------------
# SEED CATEGORIES, PRODUCTS AND IMAGES
# ------------------------------------------------------------

json_files.each do |json_file|
  file_path = json_file[:path]
  unless File.exist?(file_path)
    warn "JSON file not found: #{file_path}"
    next
  end

  puts
  puts "Reading #{file_path.basename}..."
  category = Category.find_by!(
    name: json_file[:category]
  )
  products_data = JSON.parse(
    File.read(file_path)
  )

  products_data.each_with_index do |data, index|
    puts
    puts "[#{index + 1}/#{products_data.length}] #{data["name"]}"

    # category_name = data["category"].presence || "Uncategorized"


    # Use the model number as the SKU.
    sku = data["model_number"].presence

    if sku.nil?
      warn "  Missing model number/SKU. Product skipped."
      next
    end

    # product = Product.find_or_initialize_by(
    #   sku: sku
    # )
    product = Product.find_or_initialize_by(
      sku: data["model_number"]
    )
    product.name = data["name"]
    product.description = data["description"]
    product.product_price = data["product_price"]

    # Your schema contains only one rental_price field.
    # We use the scraped daily rental price.
    product.rental_price = data["daily_price"]

    # Keep the database's existing spelling.
    product.avaliable = true
    # product.sku=sku
    product.stock_quanity = product.stock_quanity.presence || rand(3..15)

    product.category = category

    product.save!

    puts "  Product saved."
    puts "  SKU: #{product.sku}"
    puts "  Product price: #{product.product_price.inspect}"
    puts "  Rental price: #{product.rental_price.inspect}"
    puts "  Stock: #{product.stock_quanity}"

    attach_product_image(
      product,
      data["image_url"]
    )
  rescue ActiveRecord::RecordInvalid => error
    warn "  Product could not be saved:"
    warn "  #{error.record.errors.full_messages.join(", ")}"
  rescue StandardError => error
    warn "  Unexpected product error: #{error.message}"
  end
end

puts
puts "Seeding finished."
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
puts "Product images: #{ProductImage.count}"
