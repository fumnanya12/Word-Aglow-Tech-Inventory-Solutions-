# lib/scrapers/long_mcquade_scraper.rb

require "net/http"
require "nokogiri"
require "json"
require "uri"
require "fileutils"

class LongMcquadeScraper
  BASE_URL = "https://www.long-mcquade.com"

LISTING_URLS = [
  "https://www.long-mcquade.com/rentals/pa/0/21/52/",

  "https://www.long-mcquade.com/?page=rentals&PageName=pa&SubDepartmentID=52&Current=20"
].freeze

  CATEGORY_NAME = "PA Speakers"

  OUTPUT_FILENAME = "long_mcquade_pa_speakers.json"

  def scrape
    puts "Starting Long & McQuade scraper..."
    products = []

    # Visit each manually supplied listing page.
    LISTING_URLS.each_with_index do |listing_url, index|
      page_number = index + 1

      puts
      puts "Scraping listing page #{page_number}:"
      puts listing_url

      document = fetch_document(listing_url)

      unless document
        warn "Could not load listing page #{page_number}."
        next
      end

      page_products = scrape_listing_page(document)

      puts(
        "Found #{page_products.length} products " \
        "on page #{page_number}."
      )

      products.concat(page_products)

      sleep 1
    end

    # Remove any products that appeared on both pages.
    products = remove_duplicates(products)

    puts
    puts "Total unique products: #{products.length}"
    puts "Now visiting individual product pages..."

    products.each_with_index do |product, index|
      puts "[#{index + 1}/#{products.length}] #{product[:name]}"

      details = scrape_product_details(product[:source_url])

      product[:description] =
        details[:description] ||
        fallback_description(product)
        product[:product_price] =
          details[:product_price]
      product[:specifications] = details[:specifications]

      puts "  Product price: #{product[:product_price].inspect}"
      puts "  Daily rental: #{product[:daily_price].inspect}"
      puts "  Weekly rental: #{product[:weekly_price].inspect}"
      puts "  Monthly rental: #{product[:monthly_price].inspect}"

      # Be respectful to the third-party server.
      sleep 1
    end


    save_json(products)

    puts
    puts "Scraping complete."
    puts "Products saved: #{products.length}"

    products
  end

  private

  # ------------------------------------------------------------
  # LISTING PAGE
  # ------------------------------------------------------------

  def scrape_listing_page(document)
    product_cards = document.css(
      "div.products-row div.m-item"
    )

    product_cards.filter_map do |card|
      scrape_product_card(card)
    end
  end

  def scrape_product_card(card)
    link_element = card.at_css("a.link-dark-2")
    image_element = card.at_css("img")

    return nil unless link_element
    return nil unless image_element

    product_url = absolute_url(link_element["href"])
    image_url = absolute_url(image_element["src"])

    # The visible product title is shortened with "...".
    # The image alt attribute contains the full title.
    name = clean_text(image_element["alt"])

    brand = extract_brand(card)
    model_number = extract_model(card)
    prices = extract_prices(card)

    return nil if product_url.nil?
    return nil if name.empty?

    {
      category: CATEGORY_NAME,
      name: name,
      brand: brand,
      model_number: model_number,
      daily_price: prices[:daily],
      weekly_price: prices[:weekly],
      monthly_price: prices[:monthly],

      product_price: nil,
      image_url: image_url,
      source_url: product_url,
      description: nil,
      specifications: []
    }
  end

  def extract_brand(card)
    brand_element = card.at_css(
      ".products-item-descr p.fs-5"
    )

    clean_text(brand_element&.text)
  end

  def extract_model(card)
    paragraphs = card.css(
      ".products-item-descr p"
    )

    model_paragraph = paragraphs.find do |paragraph|
      clean_text(paragraph.text).start_with?("Model:")
    end

    clean_text(model_paragraph&.text)
      .sub(/\AModel:\s*/i, "")
      .strip
  end

  def extract_prices(card)
    prices = {
      daily: nil,
      weekly: nil,
      monthly: nil
    }

    card.css(".products-item-price").each do |element|
      text = clean_text(element.text)
      amount = extract_money(text)

      next if amount.nil?

      case text
      when /1\s*Day/i
        prices[:daily] = amount
      when /1\s*Week/i
        prices[:weekly] = amount
      when /1\s*Month/i
        prices[:monthly] = amount
      end
    end

    prices
  end

  def extract_money(text)
    match = text.match(
      /\$\s*(\d+(?:\.\d{1,2})?)/
    )

    return nil unless match

    match[1].to_f
  end

  # ------------------------------------------------------------
  # INDIVIDUAL PRODUCT PAGE
  # ------------------------------------------------------------

  def scrape_product_details(product_url)
    document = fetch_document(product_url)

    unless document
      warn "  Product page could not be loaded."

      return {
        description: nil,
        product_price: nil,
        specifications: []
      }
    end

    {
      description: extract_description(document),
       product_price: extract_product_price(document),
      specifications: extract_specifications(document)
    }
  end

  def extract_description(document)
    # Try structured metadata first.
    json_ld_description =
      extract_json_ld_description(document)

    return json_ld_description if present_text?(
      json_ld_description
    )

    # Product pages commonly include a useful meta description.
    meta_description = document.at_css(
      'meta[name="description"]'
    )&.[]("content")

    meta_description = clean_text(meta_description)

    return meta_description if valid_description?(
      meta_description
    )

    # These selectors provide fallbacks if the page structure changes.
    selectors = [
      "#description",
      "#product-description",
      ".product-description",
      ".product-details-description",
      ".description",
      ".tab-pane",
      ".tab-content"
    ]

    selectors.each do |selector|
      elements = document.css(selector)

      elements.each do |element|
        text = clean_description(element.text)

        return text if valid_description?(text)
      end
    end

    nil
  end

  def extract_json_ld_description(document)
    document.css(
      'script[type="application/ld+json"]'
    ).each do |script|
      next if script.text.strip.empty?

      begin
        data = JSON.parse(script.text)

        description = find_description_in_json(data)

        return clean_description(description) if present_text?(
          description
        )
      rescue JSON::ParserError
        next
      end
    end

    nil
  end

  def find_description_in_json(data)
    case data
    when Hash
      if data["description"]
        return data["description"]
      end

      data.each_value do |value|
        result = find_description_in_json(value)
        return result if present_text?(result)
      end
    when Array
      data.each do |item|
        result = find_description_in_json(item)
        return result if present_text?(result)
      end
    end

    nil
  end

  def extract_specifications(document)
    specifications = []

    # Capture table specifications.
    document.css("table tr").each do |row|
      cells = row.css("th, td").map do |cell|
        clean_text(cell.text)
      end.reject(&:empty?)

      next if cells.length < 2

      specifications << {
        name: cells.first,
        value: cells[1..].join(" ")
      }
    end

    # Some pages may use definition lists.
    document.css("dl").each do |list|
      labels = list.css("dt")
      values = list.css("dd")

      labels.each_with_index do |label, index|
        value = values[index]

        next unless value

        specifications << {
          name: clean_text(label.text),
          value: clean_text(value.text)
        }
      end
    end

    specifications
      .reject do |specification|
        specification[:name].empty? ||
          specification[:value].empty?
      end
      .uniq
  end

def extract_product_price(document)
  # Try structured product data first.
  json_ld_price = extract_json_ld_price(document)
  return json_ld_price unless json_ld_price.nil?

  # Try common price metadata.
  meta_selectors = [
    'meta[property="product:price:amount"]',
    'meta[itemprop="price"]',
    'meta[property="og:price:amount"]'
  ]

  meta_selectors.each do |selector|
    element = document.at_css(selector)
    next unless element

    value = element["content"]

    price = normalize_price(value)
    return price unless price.nil?
  end

  # Try visible price elements.
  price_selectors = [
    "[itemprop='price']",
    ".product-price",
    ".price",
    ".selling-price",
    ".current-price",
    ".price-value",
    "[class*='product-price']",
    "[class*='selling-price']"
  ]

  price_selectors.each do |selector|
    document.css(selector).each do |element|
      text = clean_text(
        element["content"] || element.text
      )

      price = extract_money_value(text)

      return price unless price.nil?
    end
  end

  nil
end

def extract_money_value(text)
  match = text.to_s.match(
    /\$\s*([\d,]+(?:\.\d{1,2})?)/
  )

  return nil unless match

  normalize_price(match[1])
end

def normalize_price(value)
  text = value.to_s
              .delete(",")
              .strip

  match = text.match(/\d+(?:\.\d{1,2})?/)

  return nil unless match

  match[0].to_f
end

def extract_json_ld_price(document)
  document.css(
    'script[type="application/ld+json"]'
  ).each do |script|
    next if script.text.strip.empty?

    begin
      data = JSON.parse(script.text)
      price = find_price_in_json(data)

      return price unless price.nil?
    rescue JSON::ParserError
      next
    end
  end

  nil
end

def find_price_in_json(data)
  case data
  when Hash
    offers = data["offers"]

    if offers.is_a?(Hash)
      price = offers["price"] ||
              offers["lowPrice"] ||
              offers["highPrice"]

      normalized = normalize_price(price)
      return normalized unless normalized.nil?
    end

    if data.key?("price")
      normalized = normalize_price(data["price"])
      return normalized unless normalized.nil?
    end

    data.each_value do |value|
      result = find_price_in_json(value)
      return result unless result.nil?
    end

  when Array
    data.each do |item|
      result = find_price_in_json(item)
      return result unless result.nil?
    end
  end

  nil
end
  # ------------------------------------------------------------
  # HTTP REQUEST
  # ------------------------------------------------------------

  def fetch_document(url, redirect_limit = 5)
    raise "Too many redirects" if redirect_limit.zero?

    uri = URI.parse(url)

    request = Net::HTTP::Get.new(uri)

    request["User-Agent"] =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " \
      "AppleWebKit/537.36 Chrome/120.0 Safari/537.36"

    request["Accept"] =
      "text/html,application/xhtml+xml," \
      "application/xml;q=0.9,*/*;q=0.8"

    request["Accept-Language"] = "en-CA,en;q=0.9"

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: 15,
      read_timeout: 30
    ) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      Nokogiri::HTML(
        response.body,
        nil,
        response.type_params["charset"] || "UTF-8"
      )
    when Net::HTTPRedirection
      redirected_url = absolute_url(
        response["location"]
      )

      fetch_document(
        redirected_url,
        redirect_limit - 1
      )
    else
      warn(
        "Request failed for #{url}: " \
        "#{response.code} #{response.message}"
      )

      nil
    end
  rescue StandardError => error
    warn "Request error for #{url}: #{error.message}"
    nil
  end

  # ------------------------------------------------------------
  # HELPERS
  # ------------------------------------------------------------

  def absolute_url(value)
    return nil if value.nil?
    return nil if value.strip.empty?

    URI.join(BASE_URL, value).to_s
  rescue URI::InvalidURIError
    nil
  end

  def clean_text(value)
    value.to_s
         .encode(
           "UTF-8",
           invalid: :replace,
           undef: :replace,
           replace: ""
         )
         .gsub("\u00A0", " ")
         .gsub(/\s+/, " ")
         .strip
  end

  def clean_description(value)
    clean_text(value)
      .gsub(/Product Reviews.*\z/i, "")
      .gsub(/Related Products.*\z/i, "")
      .strip
  end

  def present_text?(value)
    !value.nil? && !clean_text(value).empty?
  end

  def valid_description?(value)
    text = clean_text(value)

    return false if text.length < 40
    return false if text.length > 5_000

    true
  end

  def fallback_description(product)
    description = product[:name].dup

    unless product[:brand].empty?
      description += " by #{product[:brand]}"
    end

    unless product[:model_number].empty?
      description +=
        ", model #{product[:model_number]}"
    end

    description +
      ". Available for PA systems, events, presentations, " \
      "performances, and equipment rental."
  end

  def remove_duplicates(products)
    products.uniq do |product|
      [
        product[:model_number].downcase,
        product[:source_url].downcase
      ]
    end
  end

  def save_json(products)
    directory = Rails.root.join(
      "db",
      "data"
    )

    filepath = directory.join(
      OUTPUT_FILENAME
    )

    FileUtils.mkdir_p(directory)

    File.write(
      filepath,
      JSON.pretty_generate(products)
    )

    puts "Saved JSON to:"
    puts filepath
  end
end
