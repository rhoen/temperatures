require 'pry'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require './models/device'
require './models/reading'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/devices' do
    json Device.all
  end

  post '/devices' do
    body = JSON.parse(request.body.read)
    device = Device.create!(name: body['name'], location: body['location'])

    json device
  end

  delete '/devices/:id' do |id|
    device = Device.find_by(id: id)
    if device
      json device.destroy
    else
      status 404
    end
  end

  post '/readings' do
    body = JSON.parse(request.body.read)
    device = Device.find_by(id: body['device_id'])
    if device
      reading = Reading.create(
        device: device,
        temperature: body['temperature'],
        location: device.location
      )
      json reading
    else
      status 404
    end
  end

  get '/readings' do
    json ({ readings: Reading.all.order(created_at: :desc).limit(1000) })
  end
end

App.run! if __FILE__ == $PROGRAM_NAME
