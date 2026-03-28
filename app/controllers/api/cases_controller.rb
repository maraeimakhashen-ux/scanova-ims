module Api
  class CasesController < ApplicationController
    def index
      search = params[:search]
      status_filter = params[:status]
      pathologist_filter = params[:pathologist]
      page = (params[:page] || 1).to_i
      limit = (params[:limit] || 50).to_i
      offset = (page - 1) * limit

      scope = ImsCase.all
      if search.present?
        scope = scope.where(
          "accession_number ILIKE :q OR patient_identifier ILIKE :q OR patient_name ILIKE :q OR organ_site ILIKE :q",
          q: "%#{search}%"
        )
      end
      scope = scope.where(status: status_filter) if status_filter.present?
      scope = scope.where(pathologist: pathologist_filter) if pathologist_filter.present?

      total = scope.count
      cases = scope.order(created_at: :asc).limit(limit).offset(offset)

      render json: {
        cases: cases.map { |c| serialize_case_list(c) },
        total: total,
        page: page,
        limit: limit
      }
    end

    def show
      kase = ImsCase.find(params[:id])
      blocks = kase.ims_blocks.order(:block_code).includes(:ims_slides)
      all_slides = kase.ims_slides.order(:sort_order)

      blocks_with_slides = blocks.map do |block|
        slides = all_slides.select { |s| s.ims_block_id == block.id }
        block_data = serialize_block(block)
        block_data[:slides] = slides.map { |s| serialize_slide(s, kase, block) }
        block_data[:slideCount] = slides.count
        block_data
      end

      render json: serialize_case_detail(kase, blocks_with_slides)
    end

    def create
      kase = ImsCase.new(case_params)
      kase.status ||= "active"
      kase.report_status ||= "draft"
      if kase.save
        render json: serialize_case_detail(kase, []), status: :created
      else
        render json: { error: kase.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def update
      kase = ImsCase.find(params[:id])
      if kase.update(case_params)
        render json: serialize_case_detail(kase, kase.ims_blocks.order(:block_code).includes(:ims_slides).map { |b|
          bd = serialize_block(b)
          bd[:slides] = kase.ims_slides.where(ims_block_id: b.id).order(:sort_order).map { |s| serialize_slide(s, kase, b) }
          bd[:slideCount] = bd[:slides].count
          bd
        })
      else
        render json: { error: kase.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def destroy
      kase = ImsCase.find(params[:id])
      kase.destroy
      render json: { success: true }
    end

    def flags
      kase = ImsCase.find(params[:id])
      allowed = %w[is_volunteer archive_read_at]
      attrs = params.permit(allowed).to_h
      if kase.update(attrs)
        render json: serialize_case_list(kase)
      else
        render json: { error: kase.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def sign
      kase = ImsCase.find(params[:id])
      kase.update!(report_status: "signed", signed_at: Time.current)
      render json: serialize_case_detail(kase, [])
    end

    private

    def case_params
      params.permit(
        :accession_number, :patient_identifier, :patient_name, :patient_age, :patient_gender,
        :specimen_type, :organ_site, :collection_date, :uploaded_date, :pathologist,
        :status, :specimen_origin, :specimen_size, :referral_doctor, :referral_clinic,
        :clinical_history, :gross_description, :microscopic_description, :diagnosis,
        :diagnosis_category, :report_status, :notes, :corrected_at, :is_volunteer,
        :signed_at, :archive_read_at
      )
    end

    def slide_count_for(kase)
      kase.ims_slides.count
    end

    def block_count_for(kase)
      kase.ims_blocks.count
    end

    def serialize_case_list(kase)
      {
        id: kase.id,
        accessionNumber: kase.accession_number,
        patientIdentifier: kase.patient_identifier,
        patientName: kase.patient_name,
        patientAge: kase.patient_age,
        patientGender: kase.patient_gender,
        specimenType: kase.specimen_type,
        organSite: kase.organ_site,
        specimenOrigin: kase.specimen_origin,
        specimenSize: kase.specimen_size,
        referralDoctor: kase.referral_doctor,
        referralClinic: kase.referral_clinic,
        collectionDate: kase.collection_date,
        uploadedDate: kase.uploaded_date,
        pathologist: kase.pathologist,
        status: kase.status,
        reportStatus: kase.report_status,
        isVolunteer: kase.is_volunteer,
        signedAt: kase.signed_at,
        notes: kase.notes,
        createdAt: kase.created_at,
        updatedAt: kase.updated_at,
        slideCount: kase.ims_slides.count,
        blockCount: kase.ims_blocks.count,
        pendingRequests: kase.ims_prep_requests.where(status: %w[pending in_progress]).count,
        doneRequests: kase.ims_prep_requests.where(status: "done").count,
      }
    end

    def serialize_case_detail(kase, blocks_with_slides)
      {
        id: kase.id,
        accessionNumber: kase.accession_number,
        patientIdentifier: kase.patient_identifier,
        patientName: kase.patient_name,
        patientAge: kase.patient_age,
        patientGender: kase.patient_gender,
        specimenType: kase.specimen_type,
        organSite: kase.organ_site,
        collectionDate: kase.collection_date,
        uploadedDate: kase.uploaded_date,
        pathologist: kase.pathologist,
        status: kase.status,
        reportStatus: kase.report_status,
        signedAt: kase.signed_at,
        correctedAt: kase.corrected_at,
        clinicalHistory: kase.clinical_history,
        specimenOrigin: kase.specimen_origin,
        specimenSize: kase.specimen_size,
        referralDoctor: kase.referral_doctor,
        referralClinic: kase.referral_clinic,
        grossDescription: kase.gross_description,
        microscopicDescription: kase.microscopic_description,
        diagnosis: kase.diagnosis,
        diagnosisCategory: kase.diagnosis_category,
        notes: kase.notes,
        isVolunteer: kase.is_volunteer,
        archiveReadAt: kase.archive_read_at,
        createdAt: kase.created_at,
        updatedAt: kase.updated_at,
        slideCount: kase.ims_slides.count,
        blockCount: kase.ims_blocks.count,
        blocks: blocks_with_slides,
      }
    end

    def serialize_block(block)
      {
        id: block.id,
        caseId: block.ims_case_id,
        blockCode: block.block_code,
        specimenPart: block.specimen_part,
        notes: block.notes,
        createdAt: block.created_at,
        updatedAt: block.updated_at,
      }
    end

    def serialize_slide(slide, kase, block)
      {
        id: slide.id,
        caseId: slide.ims_case_id,
        blockId: slide.ims_block_id,
        slideCode: slide.slide_code,
        fullLabelText: slide.full_label_text,
        stainType: slide.stain_type,
        antibodyMarker: slide.antibody_marker,
        levelNumber: slide.level_number,
        recutFlag: slide.recut_flag,
        scannerName: slide.scanner_name,
        scanDate: slide.scan_date,
        uploadDate: slide.upload_date,
        fileName: slide.file_name,
        filePath: slide.file_path,
        thumbnailPath: slide.thumbnail_path,
        labelImagePath: slide.label_image_path,
        barcode: slide.barcode,
        magnification: slide.magnification,
        dimensions: slide.dimensions,
        fileSize: slide.file_size,
        qcStatus: slide.qc_status,
        workflowStatus: slide.workflow_status,
        viewerUrl: slide.viewer_url,
        rackRow: slide.rack_row,
        rackPosition: slide.rack_position,
        sortOrder: slide.sort_order,
        tags: slide.tags || [],
        notes: slide.notes,
        createdAt: slide.created_at,
        updatedAt: slide.updated_at,
        accessionNumber: kase.accession_number,
        blockCode: block&.block_code,
        organSite: kase.organ_site,
      }
    end
  end
end
