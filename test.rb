require './okikisen'
require 'pry'

def should_eq a, b
  unless a==b
    puts 'unmatched'
    puts "#{a}"
    puts "#{b}"
    binding.pry
    raise 'unmatched'
  end
end

normal = Okikisen.new %(
2014/11/22 AM06:30現在 

●高速船ﾚｲﾝﾎﾞｰｼﾞｪｯﾄ 
定期運航 

●フェリーおき 
定期運航 

●フェリーくにが 
定期運航 

●フェリーしらしま 
定期運航 


隠岐の海況（波高） 
本日1.5m～1.5m 
明日1.0m～1.0m 
)

error = Okikisen.new %(
高速船ﾚｲﾝﾎﾞｰｼﾞｪｯﾄ
定期運航

フェリーおき
終日運休

フェリーしらしま
12月31日（水）　荒天のため臨時ダイヤで運航します
西郷発 8:30
ほげ着 8:40
あああ

隠岐の海況（波高） 
本日2.5m～3.5m 
明日4.5m～7.0m 
)

should_eq(
  %w(date time wave_today wave_tomorrow).map{|name|normal.send name},
  %w(2014/11/22 AM06:30 1.5m～1.5m 1.0m～1.0m)
)

should_eq(
  %w(date time wave_today wave_tomorrow).map{|name|error.send name},
  [nil, nil, '2.5m～3.5m', '4.5m～7.0m']
)

should_eq(
  error.error_ships,
  {
    'フェリーおき' => '終日運休',
    'フェリーしらしま' => 
%(12月31日（水）　荒天のため臨時ダイヤで運航します
西郷発 8:30
ほげ着 8:40
あああ)
  }
)

should_eq normal.messages(prev: normal), []
should_eq normal.messages(prev: error), []
should_eq error.messages(prev: error), []

should_eq(
  error.messages(prev: normal),
  [
%(フェリーおき
終日運休),
%(フェリーしらしま
12月31日（水）　荒天のため臨時ダイヤで運航します
西郷発 8:30
ほげ着 8:40
あああ)
  ]
)

