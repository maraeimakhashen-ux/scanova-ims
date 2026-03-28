module Api
  class DashboardController < ApplicationController
    def stats
      total = ImsSlide.count
      today_start = Time.current.beginning_of_day
      today_slides = ImsSlide.where("upload_date >= ?", today_start)
      today_count = today_slides.count
      today_storage = today_slides.sum(:file_size)
      pending_qc = ImsSlide.where(qc_status: "pending").count
      archived = ImsSlide.where(workflow_status: "archived")
      deleted = ImsSlide.where(qc_status: "deleted")
      total_storage = ImsSlide.sum(:file_size)

      stain_results = ImsSlide.group(:stain_type).count.map { |t, c| { stainType: t, count: c } }
      workflow_results = ImsSlide.group(:workflow_status).count.map { |w, c| { workflowStatus: w, count: c } }

      recent_slides = ImsSlide.includes(:ims_case, :ims_block)
        .order(created_at: :desc).limit(10)
        .map { |s| { id: s.id, slideCode: s.slide_code, stainType: s.stain_type,
                     qcStatus: s.qc_status, workflowStatus: s.workflow_status,
                     uploadDate: s.upload_date, accessionNumber: s.ims_case&.accession_number,
                     blockCode: s.ims_block&.block_code, organSite: s.ims_case&.organ_site } }

      recent_cases = ImsCase.order(created_at: :desc).limit(5)
        .map { |c| { id: c.id, accessionNumber: c.accession_number, patientIdentifier: c.patient_identifier,
                     patientName: c.patient_name, specimenType: c.specimen_type, organSite: c.organ_site,
                     status: c.status, pathologist: c.pathologist, createdAt: c.created_at,
                     slideCount: c.ims_slides.count, blockCount: c.ims_blocks.count } }

      render json: {
        totalSlides: total,
        slidesUploadedToday: today_count,
        todayStorageBytes: today_storage,
        slidesPendingQc: pending_qc,
        archivedSlides: archived.count,
        archivedStorageBytes: archived.sum(:file_size),
        deletedSlides: deleted.count,
        deletedStorageBytes: deleted.sum(:file_size),
        totalStorageBytes: total_storage,
        storageCapacityBytes: 2 * 1024 * 1024 * 1024 * 1024,
        slidesByStain: stain_results,
        slidesByWorkflowStatus: workflow_results,
        recentSlides: recent_slides,
        recentCases: recent_cases,
      }
    end
  end
end
