require 'open-uri'
require 'nokogiri'

class Okikisen
  attr_reader :text
  def initialize text
    @text = text
  end

  def self.scrape
    # url = 'http://www.oki-kisen.co.jp/'
    url = 'https://dl.dropboxusercontent.com/u/102060740/okikisen.html'
    html = Nokogiri.HTML open(url).read
    html.css('#situationArea').text
  end

  def self.patterns
    {
      date: /2\d{3}\/\d\d\/\d\d/,
      time: /[AP]M\d\d:\d\d/,
      wave_today: /本日([\d.]+m.[\d.]+m)/,
      wave_tomorrow: /明日([\d.]+m.[\d.]+m)/
    }
  end

  patterns.each do |name, pattern|
    define_method(name){@text.match(pattern).to_a.last}
  end

  def ship_names
    %w(高速船ﾚｲﾝﾎﾞｰｼﾞｪｯﾄ フェリーおき フェリーくにが フェリーしらしま)
  end

  def splitter
    %w(隠岐の海況)
  end

  def ships
    out = Hash[ship_names.map{|name|[name, '']}]
    current = nil
    ship_patterns = {
      
    }
    @text.split(/\r|\n/).each do |line|
      ship = ship_names.find{|s|line.include? s}
      if ship
        current = ship
      elsif splitter.any?{|s|line.include? s}
        current = nil
      elsif current
        out[current] << line+"\n"
      end
    end
    Hash[out.map{|k,v|
      [k, v.strip]
    }]
  end

  def normal_pattern? text
    text =~ /^(定期|通常|平常)(通り)?(運行|運航)$/
  end

  def error_ships
    ships.reject{|k,v|v.empty? || normal_pattern?(v)}
  end

  def as_json
    Hash[self.class.patterns.keys.map{|key|[key, send(key)]}].merge error_ships: error_ships
  end

  def messages prev: nil
    return [] if prev.nil? || as_json == prev.as_json || error_ships.empty?
    error_ships.map do |name, text|
      [name, text].join "\n"
    end
  end
end
