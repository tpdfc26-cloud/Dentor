# DENTOR Web App — Phase 1

A runnable **online multi-user application foundation** based on the uploaded DENTOR HTML. Includes PostgreSQL persistence, login, staff roles, patient registration/search/profiles, clinical records, appointments and live dashboard counts.

## Requirements
Node.js 20+, PostgreSQL 15+.

## Local setup
1. Create a PostgreSQL database called `dentor` and database user with appropriate permissions.
2. Run `psql -d dentor -f server/schema.sql` (with your database credentials).
3. Copy `.env.example` to `.env` and set a strong `DATABASE_URL` and random `JWT_SECRET`.
4. Run `npm install`.
5. Create the first administrator: `node server/create-admin.js "Clinic Admin" admin@example.com "your-unique-strong-password"`.
6. Run `npm start` and open `http://localhost:3000`.

## Deploying
Use a managed PostgreSQL database and Node.js hosting with HTTPS. Set `NODE_ENV=production`, `DATABASE_URL`, `JWT_SECRET` and `PORT` in hosting environment settings. Run the SQL migration once and create the initial admin securely. Configure backups, TLS, log retention, and access controls before real patient use.

## Important scope limitations
This is a **working Phase 1 foundation**, not a complete migration of every module in the 1.39 MB HTML. The original source is retained at `public/original-dashboard.html` for design/workflow reference and is **not linked as a clinical production page**, because it includes demo data and insecure client-side logic. Patient data from the demo is **not automatically imported**. Clinical file upload, pharmacy, finance, lab orders, full odontogram, billing, reporting, audit log writes, staff management, and queue synchronization are not yet migrated. The frontend is a secure API-connected lightweight interface rather than a pixel-perfect React port of the original dashboard. Review privacy, consent, backup/restore, access controls, and security testing before production clinical use.


## Phase 2 modules
Run the updated `server/schema.sql` against the same PostgreSQL database (all statements are `IF NOT EXISTS`), then restart the Node server. New database-backed sections: invoices and partial payments, inventory with low-stock warnings, and three-chair queue. Only Admin/Reception can create invoices and payments; Admin/Staff can manage inventory; Admin/Dentist/Reception can manage the queue.

These are foundational workflows, not a production-certified healthcare system. Clinical imaging binary storage, audit logging for every operation, comprehensive role/tenant isolation, backup/restore, CSRF protection, user provisioning, and complete billing/GST logic remain to be implemented and security-reviewed before handling real patient data. Use HTTPS in production.


## Full-phase expansion (October 2026)
New features: e-prescriptions, secure clinical file uploads/downloads, staff account creation, financial/operational reporting, appointment status API, audit viewer. Run updated `server/schema.sql` against your existing PostgreSQL database before starting.

**Deployment and clinical safety:** This package is a development implementation, not certified clinical software. Use HTTPS, managed PostgreSQL backups, encrypted private file storage, tested restore procedures, security reviews, and a clinical/legal compliance review before using real patient data. The original HTML remains in `public/original-dashboard.html` for design reference; its entire UI has NOT been fully migrated. No real patient data has been imported. Do not expose the original HTML file on a public production server because it contains a hard-coded demonstration password and mock patient data.

## Phase 4: Dental Lab & Attendance
Added database-backed lab orders with workflow statuses and audit entries, plus self-service staff check-in/check-out and an admin daily attendance register. Apply the appended `server/schema.sql` migrations before restarting. This is still a development build; production hardening and complete original UI migration remain outstanding.


## Final-stage modules
- Database-backed 32-tooth FDI odontogram; dentist/admin can update conditions and notes.
- Monthly payroll with gross pay, deductions, net calculation and administrator-only access.
- Existing Phase 1–4 modules remain included.

## Security and production readiness
This is a **development build**, not a certified or fully tested production dental record system. Do not upload real patient records before a security/privacy review. In particular: add CSRF defenses for cookie-based authentication; remove `contentSecurityPolicy:false` after adjusting frontend scripts; configure TLS, encrypted database and file backups, monitoring, retention and disaster recovery; test all role restrictions; validate file contents rather than MIME alone; and verify applicable Indian health-data, privacy, invoicing and tax requirements with qualified professionals. Existing invoices are not represented as GST-compliant tax invoices.

Run `npm install`, create `.env` from `.env.example`, create the PostgreSQL database, execute `psql "$DATABASE_URL" -f server/schema.sql`, create the administrator per `server/create-admin.js`, then `npm start`. PostgreSQL and integration tests were not run in this environment.
