require './spec/spec_helper'
require './app'
require 'rack/test'

include Rack::Test::Methods

describe App do
  def app
    App
  end

  describe 'Get#devices' do
    it 'returns a 200' do
      get '/devices'
      expect(last_response).to be_ok
    end
  end

  describe 'Post#devices' do
    let(:body) { {name: 'test', location: 'here'}.to_json }
    it 'returns 200' do
      post '/devices', body
      expect(last_response).to be_ok
    end

    it 'returns correct keys' do
      post 'devices', body
      response = JSON.parse(last_response.body)
      expect(response.keys).to include('name', 'location')
    end

    it 'creates a device' do
      expect{post '/devices', body}.to change{Device.count}.from(0).to(1)
    end
  end

  describe 'Post#readings' do
    let(:device_id) { device.id }
    let(:name) { 'testname 1' }
    let(:location) { 'room1' }
    let(:temperature) { 75 }
    let(:body) { {device_id: device.id, temperature: temperature}.to_json }
    let!(:device) { Device.create(name: name, location: location) }

    before do
      post '/readings', body
    end

    it 'returns a 200' do
      expect(last_response).to be_ok
    end

    it 'creates a reading' do
      expect(Reading.count).to eq(1)
    end

    it 'returns the location' do
      response = JSON.parse(last_response.body)
      expect(response['location']).to eq(location)
    end

    it 'returns the device id' do
      response = JSON.parse(last_response.body)
      expect(response['device_id']).to eq(device_id)
    end

    context 'the reading' do
      it 'belongs to the device' do
        expect(Reading.last.device).to eq(device)
      end

      it 'has a temperature' do
        expect(Reading.last.temperature).to eq(temperature)
      end

      it 'has a created_at' do
        expect(Reading.last.created_at).to be_a(Time)
      end
    end
  end

  describe 'GET#readings' do
    before do
      3.times { |i| Reading.create(temperature: i) }
    end

    before do
      get '/readings'
    end

    it 'lists the readings' do
      response = JSON.parse(last_response.body)
      expect(response['readings'].length).to eq(3)
    end

    it 'returns most recent reading first' do
      response = JSON.parse(last_response.body)
      expect(response['readings'][0]['temperature']).to eq(2)
    end
  end

  describe 'Delete#device' do
    let!(:device) { Device.create(name: 'test', location: 'test') }

    it 'deletes the device' do
      expect {delete "/devices/#{device.id}"}.to change{
        Device.count
      }.from(1).to (0)
    end

    context 'not found device' do
      it 'returns 400' do
        delete '/devices/1000'
        expect(last_response.status).to eq(404)
      end
    end
  end
end
