require 'sinatra/activerecord'

class PageLog < ActiveRecord::Base
  def self.cleanup
    first.destroy if count > 2000
  end
end