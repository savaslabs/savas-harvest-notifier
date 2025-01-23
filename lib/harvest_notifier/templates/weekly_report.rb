# frozen_string_literal: true

require "harvest_notifier/templates/base"

module HarvestNotifier
  module Templates
    class WeeklyReport < Base
      REMINDER_TEXT = "*Don't forget to log your hours in Harvest every day. It is crucial for our business.*"
      USERS_LIST_TEXT = "Here is a list of people who are missing hours for last week: *%<period>s*"
      REPORT_NOTICE_TEXT = "_Log your time now and react with_ :white_check_mark:"
      SLACK_ID_ITEM = "• <@%<slack_id>s>: *%<missing_hours>s* hours missing of %<weekly_capacity>s"
      FULL_NAME_ITEM = "• %<full_name>s: *%<missing_hours>s* hours missing of %<weekly_capacity>s"

      def generate # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Jbuilder.encode do |json| # rubocop:disable Metrics/BlockLength
          json.channel channel
          json.blocks do # rubocop:disable Metrics/BlockLength
            # Reminder text
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text REMINDER_TEXT
              end
            end

            # Pretext list of users
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text format(USERS_LIST_TEXT, period: formatted_period)
              end
            end

            # List of users
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text users_list
              end
            end

            # Report notice
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text REPORT_NOTICE_TEXT
              end
            end

            # Report Time button
            json.child! do
              json.type "actions"
              json.elements do
                json.child! do
                  json.type "button"
                  json.url url
                  json.style "primary"
                  json.text do
                    json.type "plain_text"
                    json.text "Log Time"
                  end
                end

                # json.child! do
                #   json.type "button"
                #   json.text do
                #     json.type "plain_text"
                #     json.text ":repeat: Refresh"
                #   end
                #   json.value refresh_value
                # end
              end
            end
          end
        end
      end

      private

      def formatted_period
        "#{assigns[:date_from].strftime('%d %b')} - #{assigns[:date_to].strftime('%d %b %Y')}"
      end

      def users_list
        round_hours(assigns[:users])
          .map { |u| u[:slack_id].empty? ? format(FULL_NAME_ITEM, u) : format(SLACK_ID_ITEM, u) }
          .join("\n")
      end

      def round_hours(users)
        users.each do |u|
          u[:missing_hours] = u[:missing_hours].round(2)
          u[:weekly_capacity] = u[:weekly_capacity].round(2)
        end
      end

      def refresh_value
        "weekly:#{assigns[:date_from]}:#{assigns[:date_to]}"
      end
    end
  end
end
