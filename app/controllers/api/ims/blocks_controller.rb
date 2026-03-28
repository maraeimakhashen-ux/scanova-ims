module Api
  module Ims
    class BlocksController < ApplicationController
      def index
        kase = ImsCase.find(params[:case_id])
        blocks = kase.ims_blocks.order(:block_code).includes(:ims_slides)
        render json: blocks.map { |b|
          {
            id: b.id,
            caseId: b.ims_case_id,
            blockCode: b.block_code,
            specimenPart: b.specimen_part,
            notes: b.notes,
            createdAt: b.created_at,
            updatedAt: b.updated_at,
            slideCount: b.ims_slides.count,
          }
        }
      end

      def create
        kase = ImsCase.find(params[:case_id])
        block = kase.ims_blocks.new(block_params)
        if block.save
          render json: serialize_block(block), status: :created
        else
          render json: { error: block.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def update
        block = ImsBlock.find(params[:id])
        if block.update(block_params)
          render json: serialize_block(block)
        else
          render json: { error: block.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def destroy
        block = ImsBlock.find(params[:id])
        block.destroy
        render json: { success: true }
      end

      private

      def block_params
        params.permit(:block_code, :specimen_part, :notes)
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
          slideCount: block.ims_slides.count,
        }
      end
    end
  end
end