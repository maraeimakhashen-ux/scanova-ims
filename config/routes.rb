Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :ims do
      get "healthz" => "health#show"
      get "dashboard/stats" => "dashboard#stats"

      resources :cases, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch :flags
          post :sign
        end

        resources :blocks, only: [:index, :create], controller: "blocks", param: :case_id

        resources :attachments, only: [:index, :create], controller: "attachments" do
          collection do
            delete :bulk_delete, path: "bulk-delete"
          end
        end

        get "documents" => "attachments#documents_index"

        get "gross-images" => "attachments#gross_images_index"

        get  "prep-requests"     => "prep_requests#index"
        post "prep-requests"     => "prep_requests#create"

        get  "sub-reports"       => "sub_reports#index"
        post "sub-reports"       => "sub_reports#create"

        get  "report-pdf"        => "report_pdf#show"
        get  "report-shares"     => "report_pdf#report_shares_index"
        post "report-shares"     => "report_pdf#create_report_share"
      end

      resources :blocks, only: [:update, :destroy]

      resources :slides, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch :update_qc, path: "qc"
          get  :qrcode
          get  "qrcode/data" => "slides#qrcode_data"
        end
        collection do
          post :upload
          post :batch_delete,  path: "batch-delete"
          patch :batch_update, path: "batch-update"
        end
      end

      delete "documents/:id"    => "attachments#destroy_document"
      delete "gross-images/:id" => "attachments#destroy_gross_image"

      patch "prep-requests/:id" => "prep_requests#update"
      delete "prep-requests/:id" => "prep_requests#destroy"

      patch "sub-reports/:id" => "sub_reports#update"

      resources :shares, only: [:index, :create, :update] do
        collection do
          get "reason-disclaimers"             => "shares#reason_disclaimers"
          put "reason-disclaimers/:reason"     => "shares#update_reason_disclaimer", constraints: { reason: /[^\/]+/ }
        end
      end

      get "reason-disclaimers"             => "shares#reason_disclaimers"
      put "reason-disclaimers/:reason"     => "shares#update_reason_disclaimer", constraints: { reason: /[^\/]+/ }

      post "shares/:token/validate"  => "shares#validate"
      get  "shares/:token/case"      => "shares#shared_case"
      get  "shares/:token/comments"  => "shares#comments"
      post "shares/:token/comments"  => "shares#create_comment"

      get    "contacts"    => "shares#contacts"
      post   "contacts"    => "shares#create_contact"
      delete "contacts/:id" => "shares#destroy_contact"

      get "queue/shared"    => "shares#queue_shared"
      get "queue/volunteer" => "queues#volunteer"
      get "queue/archive"   => "queues#archive"

      get   "notifications"               => "notifications#index"
      get   "notifications/unread-count"  => "notifications#unread_count"
      patch "notifications/read-all"      => "notifications#mark_all_read"
      patch "notifications/:id/read"      => "notifications#mark_read"

      get    "staff"     => "notifications#staff"
      post   "staff"     => "notifications#create_staff"
      delete "staff/:id" => "notifications#destroy_staff"

      get   "messages"                => "notifications#messages"
      get   "messages/unread-count"   => "notifications#messages_unread_count"
      post  "messages"                => "notifications#create_message"
      patch "messages/read-all"       => "notifications#mark_all_messages_read"
      patch "messages/:id/read"       => "notifications#mark_message_read"

      get   "settings"                     => "settings#index"
      patch "settings"                     => "settings#update"
      get   "settings/viewer-url/:slide_id" => "settings#viewer_url"

      get "report-shares" => "report_pdf#report_shares_list"
    end
  end

  get "/ims",       to: "ims#index"
  get "/ims/*path", to: "ims#index"
  root to: "ims#index"
end
