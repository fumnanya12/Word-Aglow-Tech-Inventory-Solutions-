namespace :long_mcquade do
  desc "Scrape PA speakers and descriptions from Long & McQuade"

  task scrape_pa_speakers: :environment do
    require Rails.root.join(
      "lib",
      "scrapers",
      "long_mcquade_scraper"
    )

    LongMcquadeScraper.new.scrape
  end
   task scrape_light: :environment do
    require Rails.root.join(
      "lib",
      "scrapers",
      "light_scraper"
    )

    LightsScraper.new.scrape
  end
   task scrape_mixers: :environment do
    require Rails.root.join(
      "lib",
      "scrapers",
      "mixers_scraper"
    )

    MixersScraper.new.scrape
  end
end
