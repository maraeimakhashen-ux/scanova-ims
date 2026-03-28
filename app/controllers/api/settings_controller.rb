module Api
  module Ims
    class SettingsController < ApplicationController
      def index
        render json: ImsSetting.all_as_hash
      end

      def update
        settings_params = params.permit!.to_h.except("controller", "action", "format")
        settings_params.each do |key, value|
          ImsSetting.set(key, value.to_s) if key.is_a?(String) && !key.start_with?("_")
        end
        render json: ImsSetting.all_as_hash
      end

      def viewer_url
        slide = ImsSlide.find(params[:slide_id])
        template = ImsSetting.get("viewer_url_template") || ""
        kase = slide.ims_case
        block = slide.ims_block

        url = template
          .gsub("{slideId}", slide.id.to_s)
          .gsub("{slideCode}", slide.slide_code.to_s)
          .gsub("{accession}", kase&.accession_number.to_s)
          .gsub("{blockCode}", block&.block_code.to_s)
          .gsub("{barcode}", slide.barcode.to_s)
          .gsub("{fileName}", slide.file_name.to_s)

        render json: { url: url, slideId: slide.id, slideCode: slide.slide_code }
      end
    end
  end
end