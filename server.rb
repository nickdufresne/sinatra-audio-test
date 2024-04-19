require 'bundler'
require 'fileutils'

Bundler.require

require "sinatra"
require "sinatra/cors"

set :allow_origin, "http://localhost:4567"
set :allow_methods, "GET,HEAD,POST"


$recordings_path = File.expand_path("../recordings", __FILE__)
$mimeTypes = {
  ".webm" => "audio/webm;codecs=opus",
  ".mp4" => "audio/mp4"
}

get '/' do
  recordings = []
  Dir.glob(File.join($recordings_path, "*")).each do |file|
    recordings << [File.basename(file), $mimeTypes[File.extname(file)]]
  end
  puts recordings.inspect
  erb :audio, locals: {recordings: recordings}
end

get '/recordings/:id' do
  recording_path = File.join($recordings_path, params[:id])
  puts recording_path
  if File.exist?(recording_path)
    send_file recording_path
  else
    status 404
    erb "Not found"
  end
end

post '/recording.:type' do
  upload_file(params, params[:type])
  erb "OK"
end

def upload_file(params, extension)
  destination = File.join($recordings_path, "#{SecureRandom.hex}.#{extension}")
  FileUtils.cp(params[:recording][:tempfile].path, destination)
end
