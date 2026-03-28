# IMS → LIS Merge Guide

This guide explains how to copy the IMS (Inventory & Management System) code into
an existing Rails LIS project so both systems share one database, one Rails app,
and one deployment — with per-customer module licensing ready to use.

---

## Prerequisites

- Your LIS Rails project is running Rails 8.x with PostgreSQL.
- You have cloned / downloaded this IMS repository.
- Both apps share the **same database** (or you will run the data migration after merging).

---

## Step 1 — Copy files into the LIS project

Work from the root of the **IMS repo** and copy into the root of the **LIS project**.

### Models

```bash
cp app/models/ims_*.rb          <LIS_ROOT>/app/models/
cp app/models/module_license.rb <LIS_ROOT>/app/models/
```

### Controllers

```bash
cp app/controllers/api/attachments_controller.rb   <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/blocks_controller.rb        <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/cases_controller.rb         <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/dashboard_controller.rb     <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/notifications_controller.rb <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/prep_requests_controller.rb <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/queues_controller.rb        <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/report_pdf_controller.rb    <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/settings_controller.rb      <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/shares_controller.rb        <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/slides_controller.rb        <LIS_ROOT>/app/controllers/api/
cp app/controllers/api/sub_reports_controller.rb   <LIS_ROOT>/app/controllers/api/
```

> **Note:** `health_controller.rb` is already present in the LIS — skip it or merge
> the routes manually.

### Migrations

```bash
cp db/migrate/20240001000001_create_ims_cases.rb             <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000002_create_ims_sub_reports.rb       <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000003_create_ims_prep_requests.rb     <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000004_create_ims_blocks.rb            <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000005_create_ims_slides.rb            <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000006_create_ims_documents.rb         <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000007_create_ims_gross_images.rb      <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000008_create_ims_share_links.rb       <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000009_create_ims_share_comments.rb    <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000010_create_ims_saved_contacts.rb    <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000011_create_ims_report_shares.rb     <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000012_create_ims_reason_disclaimers.rb <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000013_create_ims_notifications.rb     <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000014_create_ims_staff_members.rb     <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000015_create_ims_staff_messages.rb    <LIS_ROOT>/db/migrate/
cp db/migrate/20240001000016_create_ims_settings.rb          <LIS_ROOT>/db/migrate/
cp db/migrate/20260327220000_drop_password_plain_from_ims_share_links.rb <LIS_ROOT>/db/migrate/
cp db/migrate/20260328000001_create_module_licenses.rb       <LIS_ROOT>/db/migrate/
```

> Skip `20260327213449_create_active_storage_tables.active_storage.rb` — Active
> Storage tables are already present in any standard Rails 8 LIS app.

### Rake tasks

```bash
cp lib/tasks/ims_data_migration.rake <LIS_ROOT>/lib/tasks/
cp lib/tasks/ims_export.rake         <LIS_ROOT>/lib/tasks/
```

---

## Step 2 — Add required gems to the LIS Gemfile

Open `<LIS_ROOT>/Gemfile` and ensure the following gems are present:

```ruby
gem "prawn"                          # PDF generation
gem "prawn-table"                    # Tables inside PDFs
gem "rqrcode"                        # QR code generation
gem "bcrypt", "~> 3.1.7"            # Password hashing for share links
gem "image_processing", "~> 1.2"    # Active Storage image variants
gem "active_storage_validations"    # File upload validation helpers
gem "rack-cors"                      # CORS headers (if not already present)
```

Then install:

```bash
bundle install
```

---

## Step 3 — Merge the routes

Add the IMS routes from `config/routes.rb` into the LIS `config/routes.rb` inside
the existing `namespace :api do … end` block. Paste all IMS routes from that block
(cases, blocks, slides, shares, attachments, etc.).

Also add the front-end catch-all if you will serve the IMS React app from the LIS:

```ruby
get "/ims",       to: "ims#index"
get "/ims/*path", to: "ims#index"
```

And add `app/controllers/ims_controller.rb` to the LIS:

```bash
cp app/controllers/ims_controller.rb <LIS_ROOT>/app/controllers/
```

---

## Step 4 — Run migrations

```bash
cd <LIS_ROOT>
rails db:migrate
```

This will create all `ims_*` tables plus the `module_licenses` table with placeholder
rows for all 8 modules (`lis`, `order_collect`, `ims`, `share`, `billing`,
`quality_qc`, `template_forms`, `ai`) for the `default` tenant.

---

## Step 5 — Import IMS data (if migrating existing data)

**Option A — SQL dump (recommended)**

From the IMS Replit, generate the SQL export:

```bash
rails ims:export_for_lis                      # writes tmp/ims_export.sql
rails ims:export_for_lis OUTPUT=/tmp/out.sql  # custom path
```

Copy `ims_export.sql` to the LIS server and run:

```bash
psql $DATABASE_URL < ims_export.sql
```

**Option B — Live DB-to-DB copy**

If both apps share the same PostgreSQL instance, use the existing rake task:

```bash
cd <LIS_ROOT>
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

# Or create from scratch:
ModuleLicense.create!(tenant_id: "acme_labs", module_name: "ims", enabled: true)
```

### Gate a feature in a controller or service

```ruby
unless ModuleLicense.licensed?(current_tenant_id, "ims")
  render json: { error: "IMS module is not enabled for your account" }, status: :forbidden
  return
end
```

### Available module names

| Key              | Module                     |
|------------------|----------------------------|
| `lis`            | Laboratory Information System |
| `order_collect`  | Order & Collect             |
| `ims`            | Inventory Management System |
| `share`          | Case Sharing                |
| `billing`        | Billing                     |
| `quality_qc`     | Quality / QC                |
| `template_forms` | Template Forms              |
| `ai`             | AI Features                 |

---

## Namespace safety

All IMS database tables use the `ims_` prefix — no collision with standard LIS
tables. All IMS models are named `Ims*` (e.g. `ImsCase`, `ImsSlide`). The single
shared model `ModuleLicense` uses no prefix because it is intentionally global.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `PG::DuplicateTable` on migrate | A table already exists; check `schema_migrations` and skip that file. |
| Missing gem error at boot | Run `bundle install` again after adding gems. |
| Active Storage errors | Ensure `rails active_storage:install` was previously run in LIS. |
| `ModuleLicense` constant missing | Ensure `module_license.rb` was copied to `app/models/`. |
