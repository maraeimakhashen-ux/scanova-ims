# IMS → LIS Merge Guide

This guide explains how to copy the IMS (Inventory & Management System) code into
an existing Rails LIS project so both systems share one database, one Rails app,
and one deployment — with per-customer module licensing ready to use.

> **Working directory for all commands in this guide:**
> The IMS repository root (the folder containing `Gemfile`, `Rakefile`, `app/`, `db/`, etc.).
> When you clone this repository, that is `scanova-ims/`. Adjust paths if you use a different checkout name.

---

## Prerequisites

- Your LIS Rails project is running Rails 8.x with PostgreSQL.
- You have cloned this IMS repository: `git clone https://github.com/maraeimakhashen-ux/scanova-ims.git`
- Both apps share the **same database** (or you will run the data migration after merging).
- `LIS_ROOT` in the commands below refers to the root directory of your LIS Rails project.

---

## Step 1 — Copy files into the LIS project

Run these commands from the **IMS repository root** (`scanova-ims/`).

### Models

```bash
cp app/models/ims_*.rb          $LIS_ROOT/app/models/
cp app/models/module_license.rb $LIS_ROOT/app/models/
```

### Controllers

The IMS controllers live in `app/controllers/api/ims/` and are namespaced as
`Api::Ims::*` (Zeitwerk-compatible path).

First create the destination directory in the LIS:

```bash
mkdir -p $LIS_ROOT/app/controllers/api/ims
```

Then copy all controllers:

```bash
cp app/controllers/api/ims/attachments_controller.rb   $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/blocks_controller.rb        $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/cases_controller.rb         $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/dashboard_controller.rb     $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/notifications_controller.rb $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/prep_requests_controller.rb $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/queues_controller.rb        $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/report_pdf_controller.rb    $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/settings_controller.rb      $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/shares_controller.rb        $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/slides_controller.rb        $LIS_ROOT/app/controllers/api/ims/
cp app/controllers/api/ims/sub_reports_controller.rb   $LIS_ROOT/app/controllers/api/ims/
```

> **Note:** `health_controller.rb` is included for completeness. If the LIS already
> has an `Api::Ims::HealthController`, skip it or merge the route manually.

### Front-end catch-all controller (optional)

Copy only if you will serve the IMS React app from the LIS:

```bash
cp app/controllers/ims_controller.rb $LIS_ROOT/app/controllers/
```

### Migrations

```bash
cp db/migrate/20240001000001_create_ims_cases.rb              $LIS_ROOT/db/migrate/
cp db/migrate/20240001000002_create_ims_sub_reports.rb        $LIS_ROOT/db/migrate/
cp db/migrate/20240001000003_create_ims_prep_requests.rb      $LIS_ROOT/db/migrate/
cp db/migrate/20240001000004_create_ims_blocks.rb             $LIS_ROOT/db/migrate/
cp db/migrate/20240001000005_create_ims_slides.rb             $LIS_ROOT/db/migrate/
cp db/migrate/20240001000006_create_ims_documents.rb          $LIS_ROOT/db/migrate/
cp db/migrate/20240001000007_create_ims_gross_images.rb       $LIS_ROOT/db/migrate/
cp db/migrate/20240001000008_create_ims_share_links.rb        $LIS_ROOT/db/migrate/
cp db/migrate/20240001000009_create_ims_share_comments.rb     $LIS_ROOT/db/migrate/
cp db/migrate/20240001000010_create_ims_saved_contacts.rb     $LIS_ROOT/db/migrate/
cp db/migrate/20240001000011_create_ims_report_shares.rb      $LIS_ROOT/db/migrate/
cp db/migrate/20240001000012_create_ims_reason_disclaimers.rb $LIS_ROOT/db/migrate/
cp db/migrate/20240001000013_create_ims_notifications.rb      $LIS_ROOT/db/migrate/
cp db/migrate/20240001000014_create_ims_staff_members.rb      $LIS_ROOT/db/migrate/
cp db/migrate/20240001000015_create_ims_staff_messages.rb     $LIS_ROOT/db/migrate/
cp db/migrate/20240001000016_create_ims_settings.rb           $LIS_ROOT/db/migrate/
cp db/migrate/20260327220000_drop_password_plain_from_ims_share_links.rb $LIS_ROOT/db/migrate/
cp db/migrate/20260328000001_create_module_licenses.rb        $LIS_ROOT/db/migrate/
```

> Skip `20260327213449_create_active_storage_tables.active_storage.rb` — Active
> Storage tables are already present in any standard Rails 8 LIS app.

### Rake tasks

```bash
cp lib/tasks/ims_data_migration.rake $LIS_ROOT/lib/tasks/
cp lib/tasks/ims_export.rake         $LIS_ROOT/lib/tasks/
```

---

## Step 2 — Add required gems to the LIS Gemfile

Open `$LIS_ROOT/Gemfile` and ensure the following gems are present:

```ruby
gem "prawn"                          # PDF generation
gem "prawn-table"                    # Tables inside PDFs
gem "rqrcode"                        # QR code generation
gem "bcrypt", "~> 3.1.7"            # Password hashing for share links
gem "image_processing", "~> 1.2"    # Active Storage image variants
gem "active_storage_validations"     # File upload validation helpers
gem "rack-cors"                      # CORS headers (if not already present)
```

Then install:

```bash
cd $LIS_ROOT
bundle install
```

---

## Step 3 — Merge the routes

All IMS routes live under `namespace :api do; namespace :ims do` — paste this
block into the existing `namespace :api do … end` block in `$LIS_ROOT/config/routes.rb`.

The IMS routes to add (inside the `namespace :api` block):

```ruby
namespace :ims do
  get "healthz" => "health#show"
  get "dashboard/stats" => "dashboard#stats"

  resources :cases, only: [:index, :show, :create, :update, :destroy] do
    member { patch :flags; post :sign }
    resources :blocks,      only: [:index, :create], controller: "blocks", param: :case_id
    resources :attachments, only: [:index, :create], controller: "attachments" do
      collection { delete :bulk_delete, path: "bulk-delete" }
    end
    get  "documents"       => "attachments#documents_index"
    get  "gross-images"    => "attachments#gross_images_index"
    get  "prep-requests"   => "prep_requests#index"
    post "prep-requests"   => "prep_requests#create"
    get  "sub-reports"     => "sub_reports#index"
    post "sub-reports"     => "sub_reports#create"
    get  "report-pdf"      => "report_pdf#show"
    get  "report-shares"   => "report_pdf#report_shares_index"
    post "report-shares"   => "report_pdf#create_report_share"
  end

  resources :blocks, only: [:update, :destroy]
  resources :slides,  only: [:index, :show, :create, :update, :destroy] do
    member do
      patch :update_qc, path: "qc"
      get   :qrcode
      get   "qrcode/data" => "slides#qrcode_data"
    end
    collection do
      post  :upload
      post  :batch_delete,  path: "batch-delete"
      patch :batch_update,  path: "batch-update"
    end
  end

  delete "documents/:id"    => "attachments#destroy_document"
  delete "gross-images/:id" => "attachments#destroy_gross_image"
  patch  "prep-requests/:id" => "prep_requests#update"
  delete "prep-requests/:id" => "prep_requests#destroy"
  patch  "sub-reports/:id"  => "sub_reports#update"

  resources :shares, only: [:index, :create, :update] do
    collection do
      get "reason-disclaimers"         => "shares#reason_disclaimers"
      put "reason-disclaimers/:reason" => "shares#update_reason_disclaimer",
          constraints: { reason: /[^\/]+/ }
    end
  end

  get  "reason-disclaimers"         => "shares#reason_disclaimers"
  put  "reason-disclaimers/:reason" => "shares#update_reason_disclaimer",
       constraints: { reason: /[^\/]+/ }

  post "shares/:token/validate" => "shares#validate"
  get  "shares/:token/case"     => "shares#shared_case"
  get  "shares/:token/comments" => "shares#comments"
  post "shares/:token/comments" => "shares#create_comment"

  get    "contacts"     => "shares#contacts"
  post   "contacts"     => "shares#create_contact"
  delete "contacts/:id" => "shares#destroy_contact"

  get "queue/shared"    => "shares#queue_shared"
  get "queue/volunteer" => "queues#volunteer"
  get "queue/archive"   => "queues#archive"

  get   "notifications"              => "notifications#index"
  get   "notifications/unread-count" => "notifications#unread_count"
  patch "notifications/read-all"     => "notifications#mark_all_read"
  patch "notifications/:id/read"     => "notifications#mark_read"

  get    "staff"     => "notifications#staff"
  post   "staff"     => "notifications#create_staff"
  delete "staff/:id" => "notifications#destroy_staff"

  get   "messages"               => "notifications#messages"
  get   "messages/unread-count"  => "notifications#messages_unread_count"
  post  "messages"               => "notifications#create_message"
  patch "messages/read-all"      => "notifications#mark_all_messages_read"
  patch "messages/:id/read"      => "notifications#mark_message_read"

  get   "settings"                      => "settings#index"
  patch "settings"                      => "settings#update"
  get   "settings/viewer-url/:slide_id" => "settings#viewer_url"

  get "report-shares" => "report_pdf#report_shares_list"
end
```

---

## Step 4 — Run migrations

```bash
cd $LIS_ROOT
rails db:migrate
```

This creates all `ims_*` tables plus the `module_licenses` table with placeholder
rows for all 8 modules (`lis`, `order_collect`, `ims`, `share`, `billing`,
`quality_qc`, `template_forms`, `ai`) for the `default` tenant.

---

## Step 5 — Import IMS data (if migrating existing data)

**Option A — SQL dump (recommended)**

From the IMS repository, generate the SQL export (requires `DATABASE_URL` pointing
at the live IMS database):

```bash
# Run from the scanova-ims/ repo root
DATABASE_URL=<ims_database_url> rails ims:export_for_lis
# → writes tmp/ims_export.sql

# Custom output path:
DATABASE_URL=<ims_database_url> rails ims:export_for_lis OUTPUT=/tmp/ims_export.sql
```

Copy `ims_export.sql` to the LIS server and import:

```bash
psql $DATABASE_URL < ims_export.sql
```

**Option B — Live DB-to-DB copy**

If both apps share the same PostgreSQL instance, you can also run the migration
task directly from the LIS project after copying the rake task:

```bash
cd $LIS_ROOT
rails ims:migrate_from_node
```

---

## Step 6 — Enable modules per customer

The `module_licenses` table and `ModuleLicense` model let you gate any feature by
tenant and module name.

### Enable a module for a tenant

```ruby
ModuleLicense.find_by(tenant_id: "acme_labs", module_name: "ims")
             &.update!(enabled: true)

# Or upsert from scratch:
ModuleLicense.find_or_create_by(tenant_id: "acme_labs", module_name: "ims")
             .update!(enabled: true)
```

### Gate a feature in a controller or service

```ruby
unless ModuleLicense.licensed?(current_tenant_id, "ims")
  render json: { error: "IMS module is not enabled for your account" }, status: :forbidden
  return
end
```

### Available module names

| Key              | Module                        |
|------------------|-------------------------------|
| `lis`            | Laboratory Information System |
| `order_collect`  | Order & Collect               |
| `ims`            | Inventory Management System   |
| `share`          | Case Sharing                  |
| `billing`        | Billing                       |
| `quality_qc`     | Quality / QC                  |
| `template_forms` | Template Forms                |
| `ai`             | AI Features                   |

---

## Namespace safety

All IMS database tables use the `ims_` prefix — no collision with standard LIS
tables. All IMS models are named `Ims*` (e.g. `ImsCase`, `ImsSlide`). All IMS
controllers are in the `Api::Ims` namespace (`module Api; module Ims; class ...`)
and live in `app/controllers/api/ims/` (Zeitwerk-compatible layout). All IMS
routes are nested under `namespace :api do; namespace :ims do`.

The single shared model `ModuleLicense` (singular) uses no prefix because it is
intentionally global to the combined LIS+IMS system. The helper method is
`ModuleLicense.licensed?` (not `ModuleLicenses`).

> **Important — use migrations, not schema.rb**: The IMS `db/schema.rb` reflects
> the shared development database and includes non-`ims_`-prefixed legacy tables.
> Do **not** copy `schema.rb` to the LIS. Always use `rails db:migrate` after
> copying the IMS migration files.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `PG::DuplicateTable` on migrate | A table already exists; check `schema_migrations` and skip that file. |
| Missing gem error at boot | Run `bundle install` again after adding gems. |
| Active Storage errors | Ensure `rails active_storage:install` was previously run in LIS. |
| `ModuleLicense` constant missing | Ensure `app/models/module_license.rb` was copied. |
| Routes not found (`404`) | Confirm IMS routes are inside `namespace :api do; namespace :ims do`. |
