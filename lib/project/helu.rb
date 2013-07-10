class Helu
  
  attr_reader :product_id, :purchase, :product

  def initialize(product_id, &result)
    @product_id = product_id
  end

# Call product to get product

  def product(&result)
    @product = Product.new(@product_id) { |product_result| result.call(product_result) }
  end

# Product variables that can be access afterwards

  def price
    price_locale = NSLocale.alloc.initWithLocaleIdentifier(App::Persistence["#{@product_id}.priceLocale"] || "en_US@currency=USD")
    price = App::Persistence["#{@product_id}.price"] || "0"

    formatter = NSNumberFormatter.alloc.init
    formatter.setFormatterBehavior(NSNumberFormatterBehavior10_4)
    formatter.setNumberStyle(NSNumberFormatterCurrencyStyle)
    formatter.setLocale(price_locale)

    formatter.stringFromNumber(price) 
  end

  def title
    App::Persistence["#{@product_id}.localizedTitle"] || "Title is not ready"
  end

  def description
    App::Persistence["#{@product_id}.localizedDescription"] || "Description is not ready"
  end

# Call purchase to purchase a product

  def purchase(&result)
    @purchase = Purchase.new(@product_id) { |purchase_result| result.call(purchase_result) }
  end

end
