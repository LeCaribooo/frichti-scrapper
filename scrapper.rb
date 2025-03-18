require 'rake'

namespace :frichti do
  desc 'Search for kebab items on Frichti'
  task :search_kebab do
    require 'httparty'
    require 'nokogiri'
    require 'selenium-webdriver'
    require 'dotenv'

    Dotenv.load

    puts 'Hello, World!'

    options = Selenium::WebDriver::Chrome::Options.new
    driver = Selenium::WebDriver.for :chrome, options: options

    driver.navigate.to('https://www.frichti.co/categorie/263637/a-la-carte')

    # Select button with id 'confidentiality-refuse-all' and click on it
    driver.find_element(id: 'confidentiality-refuse-all').click
    driver.find_element(css: '.fill.user-login').click

    driver.find_element(name: 'email').send_keys(ENV['EMAIL'])
    driver.find_element(name: 'password').send_keys(ENV['PASSWORD'])
    driver.find_element(css: 'button[type="submit"]').click

    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { driver.find_elements(css: '.item-name').size > 0 }

    product_items = driver.find_elements(css: 'a[data-id]')

    kebab_items = []
    product_items.each do |item|
      begin
        name = item.find_element(css: '.item-name').text
        price = begin
                  item.find_element(css: '.item-price span[itemprop="price"]').text
                rescue
                  'Price not found'
                end
        if name.downcase.include?('kebab')
          kebab_items << {
            name: name,
            price: price,
            id: item.attribute('data-id')
          }
        end
      rescue => e
        puts "Error checking product: #{e.message}"
      end
    end

    if kebab_items.empty?
      puts 'No kebab items found on this page.'
    else
      HTTParty.post(ENV['HOOK_URL'],)
      puts "Found #{kebab_items.size} kebab items:"
      kebab_items.each do |item|
        puts "- #{item[:name]} (#{item[:price]})"
      end
    end
  rescue => e
    puts "Error during scraping: #{e.message}"
    puts e.backtrace
  ensure
    driver.quit
    puts 'Browser closed.'
  end
end

