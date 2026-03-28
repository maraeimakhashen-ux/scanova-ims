module Api
  module Ims
    class PrepRequestsController < ApplicationController
      def index
        kase = ImsCase.find(params[:case_id])
        render json: kase.ims_prep_requests.order(created_at: :desc).map { |r| serialize(r) }
      end

      def create
        kase = ImsCase.find(params[:case_id])
        request = kase.ims_prep_requests.create!(
          block_id: params[:block_id],
          request_type: params[:request_type],
          marker_or_stain: params[:marker_or_stain],
          levels: params[:levels],
          notes: params[:notes],
          status: "pending",
          requested_by: params[:requested_by]
        )
        render json: serialize(request), status: :created
      end

      def update
        req = ImsPrepRequest.find(params[:id])
        attrs = {}
        attrs[:status] = params[:status] if params[:status]
        attrs[:completed_at] = Time.current if params[:status] == "done"
        attrs[:notes] = params[:notes] if params[:notes]
        attrs[:marker_or_stain] = params[:marker_or_stain] if params[:marker_or_stain]
        req.update!(attrs)
        render json: serialize(req)
      end

      def destroy
        ImsPrepRequest.find(params[:id]).destroy
        render json: { success: true }
      end

      private

      def serialize(r)
        {
          id: r.id,
          caseId: r.ims_case_id,
          blockId: r.block_id,
          requestType: r.request_type,
          markerOrStain: r.marker_or_stain,
          levels: r.levels,
          notes: r.notes,
          status: r.status,
          requestedBy: r.requested_by,
          completedAt: r.completed_at,
          createdAt: r.created_at,
        }
      end
    end
  end
end