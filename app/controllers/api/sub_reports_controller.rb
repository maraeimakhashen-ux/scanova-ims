module Api
  module Ims
    class SubReportsController < ApplicationController
      def index
        kase = ImsCase.find(params[:case_id])
        render json: kase.ims_sub_reports.order(created_at: :asc).map { |r| serialize(r) }
      end

      def create
        kase = ImsCase.find(params[:case_id])
        report = kase.ims_sub_reports.create!(
          sub_type: params[:type] || "addendum",
          pathologist: params[:pathologist] || kase.pathologist || "",
          report_status: "draft"
        )
        render json: serialize(report), status: :created
      end

      def update
        report = ImsSubReport.find(params[:id])
        report.update!(sub_report_params)
        render json: serialize(report)
      end

      private

      def sub_report_params
        params.permit(:clinical_history, :gross_description, :microscopic_description,
                      :diagnosis, :notes, :pathologist, :report_status, :verified_at)
      end

      def serialize(r)
        {
          id: r.id,
          caseId: r.ims_case_id,
          type: r.sub_type,
          clinicalHistory: r.clinical_history,
          grossDescription: r.gross_description,
          microscopicDescription: r.microscopic_description,
          diagnosis: r.diagnosis,
          notes: r.notes,
          pathologist: r.pathologist,
          reportStatus: r.report_status,
          verifiedAt: r.verified_at,
          createdAt: r.created_at,
          updatedAt: r.updated_at,
        }
      end
    end
  end
end