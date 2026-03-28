module Api
  class AttachmentsController < ApplicationController
    def index
      kase = ImsCase.find(params[:case_id])
      gross_images = kase.ims_gross_images.order(:sort_order).map do |img|
        { id: img.id, caseId: img.ims_case_id, blockId: img.block_id, fileName: img.file_name,
          filePath: img.file_path, thumbnailPath: img.thumbnail_path, fileSize: img.file_size,
          mimeType: img.mime_type, caption: img.caption, sortOrder: img.sort_order,
          uploadDate: img.upload_date, createdAt: img.created_at, isImage: true }
      end

      documents = kase.ims_documents.order(:created_at).map do |doc|
        { id: doc.id, caseId: doc.ims_case_id, fileName: doc.file_name, filePath: doc.file_path,
          fileSize: doc.file_size, fileType: doc.file_type, mimeType: doc.mime_type,
          category: doc.category, description: doc.description, uploadDate: doc.upload_date,
          createdAt: doc.created_at, isImage: false }
      end

      render json: (gross_images + documents).sort_by { |a| a[:createdAt] }
    end

    def create
      kase = ImsCase.find(params[:case_id])
      files = params[:files] || (params[:file] ? [params[:file]] : [])
      return render json: { error: "No files provided" }, status: :bad_request if files.empty?

      created = []
      files.each do |file|
        mime = file.content_type.to_s
        is_image = mime.start_with?("image/")
        ext = File.extname(file.original_filename).downcase

        if is_image
          img = kase.ims_gross_images.new(
            file_name: file.original_filename,
            file_size: file.size,
            mime_type: mime,
            sort_order: kase.ims_gross_images.count,
            upload_date: Time.current
          )
          img.image_file.attach(io: file.tempfile, filename: file.original_filename, content_type: mime)
          img.file_path = active_storage_url(img.image_file, file.original_filename) if img.image_file.attached?
          if img.save
            created << { id: img.id, caseId: img.ims_case_id, fileName: img.file_name,
                         filePath: img.file_path, fileSize: img.file_size, mimeType: img.mime_type,
                         uploadDate: img.upload_date, isImage: true }
          end
        else
          file_type = case ext
                      when ".pdf" then "pdf"
                      when ".doc", ".docx" then "word"
                      else "document"
                      end
          doc = kase.ims_documents.new(
            file_name: file.original_filename,
            file_size: file.size,
            file_type: file_type,
            mime_type: mime,
            upload_date: Time.current
          )
          doc.attachment_file.attach(io: file.tempfile, filename: file.original_filename, content_type: mime)
          doc.file_path = active_storage_url(doc.attachment_file, file.original_filename) if doc.attachment_file.attached?
          if doc.save
            created << { id: doc.id, caseId: doc.ims_case_id, fileName: doc.file_name,
                         filePath: doc.file_path, fileSize: doc.file_size, fileType: doc.file_type,
                         mimeType: doc.mime_type, uploadDate: doc.upload_date, isImage: false }
          end
        end
      end

      render json: { uploaded: created.length, files: created }, status: :created
    end

    def destroy_document
      doc = ImsDocument.find(params[:id])
      doc.destroy
      render json: { success: true }
    end

    def destroy_gross_image
      img = ImsGrossImage.find(params[:id])
      img.destroy
      render json: { success: true }
    end

    def bulk_delete
      doc_ids = params[:document_ids] || []
      img_ids = params[:gross_image_ids] || []
      ImsDocument.where(id: doc_ids).destroy_all
      ImsGrossImage.where(id: img_ids).destroy_all
      render json: { deleted: doc_ids.length + img_ids.length }
    end

    def documents_index
      kase = ImsCase.find(params[:case_id])
      docs = kase.ims_documents.order(:created_at)
      render json: docs.map { |d| serialize_document(d) }
    end

    def gross_images_index
      kase = ImsCase.find(params[:case_id])
      imgs = kase.ims_gross_images.order(:sort_order)
      render json: imgs.map { |img| serialize_gross_image(img) }
    end

    private

    def active_storage_url(attachment, _filename)
      return nil unless attachment.attached?
      blob = attachment.blob
      safe_name = blob.filename.to_s.gsub(/[^0-9A-Za-z.\-_]/, "_")
      "/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{safe_name}"
    end

    def serialize_document(doc)
      { id: doc.id, caseId: doc.ims_case_id, fileName: doc.file_name, filePath: doc.file_path,
        fileSize: doc.file_size, fileType: doc.file_type, mimeType: doc.mime_type,
        category: doc.category, description: doc.description, uploadDate: doc.upload_date,
        createdAt: doc.created_at }
    end

    def serialize_gross_image(img)
      { id: img.id, caseId: img.ims_case_id, blockId: img.block_id, fileName: img.file_name,
        filePath: img.file_path, thumbnailPath: img.thumbnail_path, fileSize: img.file_size,
        mimeType: img.mime_type, caption: img.caption, sortOrder: img.sort_order,
        uploadDate: img.upload_date, createdAt: img.created_at }
    end
  end
end
