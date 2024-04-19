require 'bundler'
require 'fileutils'

Bundler.require

require "sinatra"
require "sinatra/cors"
require 'browser'

set :allow_origin, "http://localhost:4567"
set :allow_methods, "GET,HEAD,POST"


$recordings_path = File.expand_path("../recordings", __FILE__)
$mimeTypes = {
  ".ogg" => "audio/ogg;codecs=opus",
  ".webm" => "audio/webm;codecs=opus",
  ".mp4" => "audio/mp4"
}

get '/' do
  recordings = []
  Dir.glob(File.join($recordings_path, "*")).sort.reverse.each do |file|
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
  browser = Browser.new request.user_agent, accept_language: request.env["HTTP_ACCEPT_LANGUAGE"]
  upload_file(params, params[:type], browser.name)
  erb "OK"
end

def upload_file(params, extension, browser)

  destination = File.join($recordings_path, "#{Time.now.to_i}-#{browser}.#{extension}")
  FileUtils.cp(params[:recording][:tempfile].path, destination)
end
