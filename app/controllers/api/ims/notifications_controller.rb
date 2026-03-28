module Api
  module Ims
    class NotificationsController < ApplicationController
      CURRENT_USER = "Dr. Reynolds"

      def index
        render json: ImsNotification.order(created_at: :desc).limit(50).map { |n| serialize(n) }
      end

      def unread_count
        count = ImsNotification.where(is_read: false).count
        render json: { count: count }
      end

      def mark_read
        ImsNotification.find(params[:id]).update!(is_read: true)
        render json: { success: true }
      end

      def mark_all_read
        ImsNotification.where(is_read: false).update_all(is_read: true)
        render json: { success: true }
      end

      def staff
        render json: ImsStaffMember.where(is_active: true).order(:name)
      end

      def create_staff
        auto_initials = params[:name].to_s.split(" ").map { |w| w[0] }.join.upcase.first(2)
        member = ImsStaffMember.create!(
          name: params[:name],
          role: params[:role] || "Staff",
          initials: params[:initials] || auto_initials
        )
        render json: member, status: :created
      end

      def destroy_staff
        ImsStaffMember.find(params[:id]).update!(is_active: false)
        render json: { success: true }
      end

      def messages
        render json: ImsStaffMessage.order(created_at: :desc).limit(50).map { |m| serialize_message(m) }
      end

      def messages_unread_count
        count = ImsStaffMessage.where(is_read: false, recipient_name: CURRENT_USER).count
        render json: { count: count }
      end

      def create_message
        msg = ImsStaffMessage.create!(
          sender_name: params[:sender_name] || CURRENT_USER,
          recipient_name: params[:recipient_name],
          subject: params[:subject],
          content: params[:content]
        )

        ImsNotification.create!(
          ntype: "staff_message",
          title: "New Message",
          message: "#{msg.sender_name} sent a message to #{msg.recipient_name}#{msg.subject ? ": #{msg.subject}" : ""}",
          source: "messaging",
          source_id: msg.id
        )

        render json: serialize_message(msg), status: :created
      end

      def mark_message_read
        ImsStaffMessage.find(params[:id]).update!(is_read: true)
        render json: { success: true }
      end

      def mark_all_messages_read
        ImsStaffMessage.where(is_read: false).update_all(is_read: true)
        render json: { success: true }
      end

      private

      def serialize(n)
        {
          id: n.id,
          type: n.ntype,
          title: n.title,
          message: n.message,
          source: n.source,
          sourceId: n.source_id,
          isRead: n.is_read,
          createdAt: n.created_at,
        }
      end

      def serialize_message(m)
        {
          id: m.id,
          senderName: m.sender_name,
          recipientName: m.recipient_name,
          subject: m.subject,
          content: m.content,
          isRead: m.is_read,
          createdAt: m.created_at,
        }
      end
    end
  end
end