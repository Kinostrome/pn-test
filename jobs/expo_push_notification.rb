# frozen_string_literal: true

module Jobs
    class ExpoPushNotification < ::Jobs::Base
      EXPO_API = "https://exp.host/--/api/v2/push/send".freeze
      
      def execute(args)
        payload = args[:payload]
        expo_pn_token = args[:expo_pn_token]
        sender = payload[:username]
        topic_title = payload[:topic_title]
        excerpt = payload[:excerpt]
        notification_type = payload[:notification_type]
        post_url = payload[:post_url]

        case notification_type
        when Notification.types[:mentioned]
          title = "#{sender} mentioned you - #{topic_title}"
          body = excerpt
        when Notification.types[:replied]
          title = "Reply from #{sender} - #{topic_title}"
          body = excerpt
        when Notification.types[:private_message]
          title = "Message from #{sender} - #{topic_title}"
          body = excerpt
        when Notification.types[:posted]
          title = "#{sender} posted in #{topic_title}"
          body = excerpt
        when Notification.types[:linked]
          title = "#{sender} linked to your post - #{topic_title}"
          body = excerpt
        else
          title = topic_title
          body = "#{sender}: #{excerpt}"
        end
  
        params = {
            "to" => expo_pn_token,
            "title" => title,
            "body" => body,
            "data" => {"discourse_url" => post_url},
        }
  
        uri = URI.parse(EXPO_API)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
  
        request = Net::HTTP::Post.new(uri.path, "Content-Type"  => "application/json")
        request.body = params.as_json.to_json
        response = http.request(request)
  
        case response
        when Net::HTTPSuccess then
          Rails.logger.info("Push notification sent successfully via Expo.")
        else
          Rails.logger.error("Expo error happened.")
          Rails.logger.error("#{request.to_yaml}")
          Rails.logger.error("#{response.to_yaml}")
        end
  
      end
    end
  end