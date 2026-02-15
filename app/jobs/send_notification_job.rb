class SendNotificationJob < ApplicationJob
  queue_as :notifications

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(event_type, incident_id)
    incident = Incident.find(incident_id)
    channels = NotificationChannel.active

    channels.find_each do |channel|
      deliver_notification(channel, event_type, incident)
    rescue StandardError => e
      Rails.logger.error(
        "[SendNotificationJob] Failed to notify channel #{channel.id} " \
        "(#{channel.channel_type}): #{e.message}"
      )
    end
  end

  private

  def deliver_notification(channel, event_type, incident)
    Rails.logger.info(
      "[SendNotificationJob] Sending #{event_type} notification " \
      "for incident '#{incident.title}' via #{channel.channel_type} (#{channel.id})"
    )
  end
end
