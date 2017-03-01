require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/' do
	"Hello world"
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']

	p body

	# 送信元がLINEであることをSHA256の照合により確認する
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
				# Reply messageの作成
        message = {
          type: 'text',
          text: event.message['text']
        }
				p message
				# 実際にReply
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)


        message = {
          type: 'text',
          text: 'ばーか'
        }
				# 実際にReply
				client.reply_message(event['replyToken'], message)
#				message = {
#					type: 'image',
#					originalContentUrl: 'https://iwiz-chie.c.yimg.jp/im_siggdT7InUlmC2sfPZsCMp8Mmw---x320-y320-exp5m-n1/d/iwiz-chie/que-10127110835',
#					previewContentUrl:	'https://iwiz-chie.c.yimg.jp/im_siggdT7InUlmC2sfPZsCMp8Mmw---x320-y320-exp5m-n1/d/iwiz-chie/que-10127110835'
#				};
      end
    end
  }

  "OK"
end
