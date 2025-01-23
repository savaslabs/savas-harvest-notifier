# frozen_string_literal: true

require "harvest_notifier/templates/base"

module HarvestNotifier
  module Templates
    class Congratulation < Base
      CONGRATS_TEXT = "Hooray, everyone logged their time for *%<period>s*! :tada:"

      def generate # rubocop:disable Metrics/MethodLength
        Jbuilder.encode do |json|
          json.channel channel
          json.blocks do
            # Reminder text
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text format(CONGRATS_TEXT, period: formatted_date)
              end
            end
          end
        end
      end

      private

      def formatted_date
        if assigns[:date]
          assigns[:date].strftime("%A, %B %d")
        else
          "#{assigns[:date_from].strftime('%A, %B %d')} - #{assigns[:date_to].strftime('%A, %B %d %Y')}"
        end
      end
    end
  end
end
