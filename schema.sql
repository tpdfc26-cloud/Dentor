CREATE TABLE IF NOT EXISTS users(id BIGSERIAL PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin','dentist','reception','staff')), created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS patients(id BIGSERIAL PRIMARY KEY, patient_code TEXT UNIQUE, name TEXT NOT NULL, age INTEGER CHECK(age BETWEEN 0 AND 120), gender TEXT, mobile TEXT, blood TEXT, doctor TEXT, treatment TEXT, risk TEXT DEFAULT 'Low', status TEXT DEFAULT 'New', allergy TEXT, history TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS clinical_records(id BIGSERIAL PRIMARY KEY, patient_id BIGINT NOT NULL REFERENCES patients(id), kind TEXT NOT NULL CHECK(kind IN ('treatment','procedure','chart')), date DATE NOT NULL DEFAULT CURRENT_DATE, name TEXT NOT NULL, tooth TEXT, doctor TEXT, status TEXT, created_by BIGINT REFERENCES users(id), created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS appointments(id BIGSERIAL PRIMARY KEY, patient_id BIGINT NOT NULL REFERENCES patients(id), doctor TEXT, starts_at TIMESTAMPTZ NOT NULL, status TEXT NOT NULL DEFAULT 'Scheduled', notes TEXT, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS audit_logs(id BIGSERIAL PRIMARY KEY, actor_id BIGINT REFERENCES users(id), action TEXT NOT NULL, entity TEXT NOT NULL, entity_id TEXT, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE INDEX IF NOT EXISTS patients_name_idx ON patients (lower(name));
CREATE INDEX IF NOT EXISTS appointments_starts_idx ON appointments (starts_at);

-- Phase 2 operational modules
CREATE TABLE IF NOT EXISTS invoices(id BIGSERIAL PRIMARY KEY,invoice_no TEXT UNIQUE,patient_id BIGINT NOT NULL REFERENCES patients(id),description TEXT NOT NULL,amount NUMERIC(12,2) NOT NULL CHECK(amount>=0),status TEXT NOT NULL DEFAULT 'Unpaid' CHECK(status IN ('Unpaid','Part Paid','Paid','Cancelled')),issued_on DATE NOT NULL DEFAULT CURRENT_DATE,created_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS payments(id BIGSERIAL PRIMARY KEY,invoice_id BIGINT NOT NULL REFERENCES invoices(id),amount NUMERIC(12,2) NOT NULL CHECK(amount>0),method TEXT NOT NULL CHECK(method IN ('Cash','UPI','Card','Bank')),reference TEXT,created_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS inventory_items(id BIGSERIAL PRIMARY KEY,name TEXT NOT NULL,sku TEXT UNIQUE,category TEXT NOT NULL DEFAULT 'General',quantity NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(quantity>=0),reorder_level NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(reorder_level>=0),unit TEXT NOT NULL DEFAULT 'pcs',updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS queue_entries(id BIGSERIAL PRIMARY KEY,patient_id BIGINT NOT NULL REFERENCES patients(id),chair INTEGER NOT NULL CHECK(chair BETWEEN 1 AND 3),token TEXT NOT NULL,status TEXT NOT NULL DEFAULT 'Waiting' CHECK(status IN ('Waiting','Called','Completed','Cancelled')),created_at TIMESTAMPTZ DEFAULT NOW(),updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE INDEX IF NOT EXISTS invoice_patient_idx ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS queue_status_idx ON queue_entries(chair,status,created_at);

-- Full-phase extensions (run after Phase 2 schema)
CREATE TABLE IF NOT EXISTS prescriptions(id BIGSERIAL PRIMARY KEY,patient_id BIGINT NOT NULL REFERENCES patients(id),doctor TEXT NOT NULL,diagnosis TEXT,medicines JSONB NOT NULL DEFAULT '[]'::jsonb,advice TEXT,created_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE IF NOT EXISTS clinical_files(id BIGSERIAL PRIMARY KEY,patient_id BIGINT NOT NULL REFERENCES patients(id),category TEXT NOT NULL CHECK(category IN ('X-ray','CBCT','OPG','Document','Photo')),original_name TEXT NOT NULL,mime_type TEXT NOT NULL,storage_name TEXT NOT NULL,bytes BIGINT NOT NULL,uploaded_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS inventory_movements(id BIGSERIAL PRIMARY KEY,item_id BIGINT NOT NULL REFERENCES inventory_items(id),delta NUMERIC(12,2) NOT NULL,reason TEXT NOT NULL,actor_id BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW());
CREATE INDEX IF NOT EXISTS clinical_files_patient_idx ON clinical_files(patient_id);
CREATE INDEX IF NOT EXISTS prescriptions_patient_idx ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS audit_created_idx ON audit_logs(created_at DESC);

-- Phase 4: dental laboratory and staff attendance
CREATE TABLE IF NOT EXISTS lab_orders(id BIGSERIAL PRIMARY KEY,patient_id BIGINT NOT NULL REFERENCES patients(id),work_type TEXT NOT NULL,teeth TEXT,shade TEXT,lab_name TEXT,requested_on DATE NOT NULL DEFAULT CURRENT_DATE,due_on DATE,status TEXT NOT NULL DEFAULT 'Requested' CHECK(status IN ('Requested','In Progress','Trial','Ready','Delivered','Cancelled')),notes TEXT,created_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW(),updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE INDEX IF NOT EXISTS lab_orders_patient_idx ON lab_orders(patient_id);
CREATE TABLE IF NOT EXISTS attendance(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id),work_date DATE NOT NULL,check_in TIMESTAMPTZ NOT NULL DEFAULT NOW(),check_out TIMESTAMPTZ,recorded_by BIGINT REFERENCES users(id),UNIQUE(user_id,work_date));
CREATE INDEX IF NOT EXISTS attendance_date_idx ON attendance(work_date);

-- Final-stage extensions
CREATE TABLE IF NOT EXISTS tooth_findings(id BIGSERIAL PRIMARY KEY,patient_id BIGINT NOT NULL REFERENCES patients(id),tooth SMALLINT NOT NULL CHECK(tooth BETWEEN 11 AND 48),condition TEXT NOT NULL CHECK(condition IN ('Healthy','Caries','Filling','RCT','Crown','Implant','Missing','Other')),notes TEXT DEFAULT '',updated_by BIGINT REFERENCES users(id),updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),UNIQUE(patient_id,tooth));
CREATE INDEX IF NOT EXISTS tooth_findings_patient_idx ON tooth_findings(patient_id);
CREATE TABLE IF NOT EXISTS payroll(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id),pay_month DATE NOT NULL,gross NUMERIC(12,2) NOT NULL CHECK(gross>=0),deductions NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(deductions>=0),notes TEXT DEFAULT '',created_by BIGINT REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW(),UNIQUE(user_id,pay_month),CHECK(deductions<=gross));
CREATE INDEX IF NOT EXISTS payroll_month_idx ON payroll(pay_month);
