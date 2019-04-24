#!/usr/bin/env ruby
require 'sinatra'
require 'digest/md5'

title      = "stamper"
stamp_file = "overlay.png"

set :bind, '0.0.0.0'

get '/' do
    @title = title
    erb :index
end

post '/load' do
    file = params["file"][:tempfile]
    md5 = Digest::MD5.hexdigest(file.read)
    geometry = `identify "#{stamp_file}"`.split(' ')[2]

    sh = <<~HEREDOC
        convert \
            -resize "#{geometry}^" \
            -gravity center \
            -crop "#{geometry}+0+0" \
            "#{file.path}" \
            "#{stamp_file}" \
            -composite "public/#{md5}.png"
    HEREDOC
    system "bash -c '#{sh}'"

    redirect to("/#{md5}.png")
end
