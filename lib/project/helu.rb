class Helu
  
  attr_reader :product_id, :shared_secret, :purchase, :product

  def initialize(product_id, shared_secret = nil, &result)
    @product_id = product_id
    @shared_secret = shared_secret
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

  def is_subscription_active?
    receipt_data = App::Persistence["#{@product_id}.receipt_data"]

    # DISPLAYING receipt data
    ap "receipt_data: #{receipt_data}"
    return false if receipt_data.blank?


    receipt_object = BW::JSON.parse(receipt_data).to_object
    expires_date = receipt_object.receipt.expires_date.to_i/1000

    return expires_date > NSDate.date.timeIntervalSince1970
  end


# Call purchase to purchase a product

  def purchase(&result)
    @purchase = Purchase.new(@product_id, @shared_secret) { |purchase_result| result.call(purchase_result) }
  end


end
