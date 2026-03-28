module Api
  class SlidesController < ApplicationController
    def index
      scope = ImsSlide.all.includes(:ims_case, :ims_block)
      scope = scope.where(ims_case_id: params[:case_id]) if params[:case_id].present?
      scope = scope.where(ims_block_id: params[:block_id]) if params[:block_id].present?
      scope = scope.where(stain_type: params[:stain_type]) if params[:stain_type].present?
      scope = scope.where(qc_status: params[:qc_status]) if params[:qc_status].present?
      scope = scope.where(workflow_status: params[:workflow_status]) if params[:workflow_status].present?
      if params[:search].present?
        q = "%#{params[:search]}%"
        scope = scope.where("slide_code ILIKE :q OR full_label_text ILIKE :q OR barcode ILIKE :q OR antibody_marker ILIKE :q", q: q)
      end

      page = (params[:page] || 1).to_i
      limit = (params[:limit] || 100).to_i
      offset = (page - 1) * limit
      total = scope.count
      slides = scope.order(sort_order: :asc).limit(limit).offset(offset)

      render json: {
        slides: slides.map { |s| serialize_slide(s) },
        total: total,
        page: page,
        limit: limit
      }
    end

    def show
      slide = ImsSlide.includes(:ims_case, :ims_block).find(params[:id])
      render json: serialize_slide(slide)
    end

    def create
      slide = ImsSlide.new(slide_params)
      max_order = ImsSlide.where(ims_case_id: slide.ims_case_id).maximum(:sort_order) || 0
      slide.sort_order ||= max_order + 1
      slide.upload_date = Time.current if slide.upload_date.nil?

      if slide.save
        render json: serialize_slide(slide), status: :created
      else
        render json: { error: slide.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def update
      slide = ImsSlide.find(params[:id])
      if slide.update(slide_params)
        render json: serialize_slide(slide)
      else
        render json: { error: slide.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def destroy
      slide = ImsSlide.find(params[:id])
      slide.destroy
      render json: { success: true }
    end

    def upload
      kase = ImsCase.find(params[:case_id])
      file = params[:file]
      return render json: { error: "A slide file is required" }, status: :bad_request if file.nil?

      block = params[:block_id].present? ? ImsBlock.find_by(id: params[:block_id], ims_case_id: kase.id) : nil
      if params[:block_id].present? && block.nil?
        return render json: { error: "Block not found or does not belong to the specified case" }, status: :bad_request
      end

      max_order = ImsSlide.where(ims_case_id: kase.id).maximum(:sort_order) || 0
      slide_code = params[:slide_code].presence || "SLIDE-#{Time.current.to_i}"

      slide = ImsSlide.new(
        ims_case: kase,
        ims_block: block,
        slide_code: slide_code,
        stain_type: params[:stain_type].presence || "H&E",
        full_label_text: params[:label_text].presence || slide_code,
        antibody_marker: params[:antibody_marker],
        barcode: params[:barcode],
        viewer_url: params[:viewer_url],
        file_name: file.original_filename,
        file_size: file.size,
        sort_order: max_order + 1,
        qc_status: "pending",
        workflow_status: "uploaded",
        upload_date: Time.current
      )

      slide.slide_file.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)

      if slide.slide_file.attached?
        blob = slide.slide_file.blob
        safe_name = blob.filename.to_s.gsub(/[^0-9A-Za-z.\-_]/, "_")
        slide.file_path = "/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{safe_name}"
      end

      if slide.save
        render json: serialize_slide(slide).merge(
          accessionNumber: kase.accession_number,
          blockCode: block&.block_code,
          organSite: kase.organ_site
        ), status: :created
      else
        render json: { error: slide.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def batch_delete
      slide_ids = params[:slide_ids] || params[:ids] || []
      ImsSlide.where(id: slide_ids).destroy_all
      render json: { deleted: slide_ids.length }
    end

    def batch_update
      slide_ids = params[:slide_ids] || params[:ids] || []
      mapped = {}
      mapped[:qc_status] = params[:qc_status] if params[:qc_status]
      mapped[:workflow_status] = params[:workflow_status] if params[:workflow_status]
      mapped[:stain_type] = params[:stain_type] if params[:stain_type]

      ImsSlide.where(id: slide_ids).update_all(mapped) unless mapped.empty?
      render json: { updated: slide_ids.length }
    end

    def update_qc
      slide = ImsSlide.find(params[:id])
      qc_attrs = {}
      qc_attrs[:qc_status] = params[:qc_status] if params[:qc_status]
      qc_attrs[:workflow_status] = params[:workflow_status] if params[:workflow_status]
      qc_attrs[:notes] = params[:notes] if params[:notes]
      slide.update(qc_attrs)
      render json: serialize_slide(slide)
    end

    def qrcode
      slide = ImsSlide.find(params[:id])
      require "rqrcode"

      label = "#{slide.ims_case&.accession_number}/#{slide.slide_code}"
      qr = RQRCode::QRCode.new(label)
      fmt = params[:format] == "svg" ? :svg : :png

      if fmt == :svg
        svg = qr.as_svg(offset: 0, color: "000", shape_rendering: "crispEdges", module_size: 4)
        render plain: svg, content_type: "image/svg+xml"
      else
        png = qr.as_png(size: 200)
        send_data png.to_s, type: "image/png", disposition: "inline"
      end
    end

    def qrcode_data
      slide = ImsSlide.find(params[:id])
      render json: {
        slideId: slide.id,
        slideCode: slide.slide_code,
        accessionNumber: slide.ims_case&.accession_number,
        blockCode: slide.ims_block&.block_code,
        stainType: slide.stain_type,
        barcode: slide.barcode,
        label: "#{slide.ims_case&.accession_number}/#{slide.slide_code}",
        qrData: "#{slide.ims_case&.accession_number}/#{slide.slide_code}",
      }
    end

    private

    def slide_params
      params.permit(
        :ims_case_id, :ims_block_id, :slide_code, :full_label_text, :stain_type,
        :antibody_marker, :level_number, :recut_flag, :scanner_name, :scan_date,
        :file_name, :file_path, :thumbnail_path, :label_image_path, :barcode,
        :magnification, :dimensions, :file_size, :qc_status, :workflow_status,
        :viewer_url, :rack_row, :rack_position, :sort_order, :notes, tags: []
      )
    end

    def serialize_slide(slide)
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
        accessionNumber: slide.ims_case&.accession_number,
        blockCode: slide.ims_block&.block_code,
        organSite: slide.ims_case&.organ_site,
      }
    end
  end
end
