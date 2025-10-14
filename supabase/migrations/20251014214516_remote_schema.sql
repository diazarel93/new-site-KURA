create type "public"."alert_level" as enum ('green', 'amber', 'red');

create type "public"."alert_status" as enum ('open', 'ack', 'closed');

create type "public"."membership_role" as enum ('player', 'coach', 'med', 'admin');

create type "public"."org_role" as enum ('player', 'coach', 'med', 'admin', 'athlete', 'staff', 'dpo', 'rgpd_manager');

create type "public"."stick_status" as enum ('pending', 'approved', 'rejected');

create sequence "public"."audit_data_events_id_seq";

create sequence "public"."audit_row_changes_id_seq";

create sequence "public"."dsar_audit_id_seq";

create sequence "public"."dsar_kms_id_seq";

create sequence "public"."rgpd_runs_run_id_seq";

create table "public"."audit_data_events" (
    "id" bigint not null default nextval('audit_data_events_id_seq'::regclass),
    "at" timestamp with time zone not null default now(),
    "table_name" text not null,
    "action" text not null,
    "row_pk" text not null,
    "org_id" uuid,
    "actor_user_id" uuid,
    "details" jsonb
);


create table "public"."audit_logs" (
    "id" bigint generated always as identity not null,
    "at" timestamp with time zone not null default now(),
    "actor_user_id" uuid,
    "org_id" uuid,
    "table_name" text not null,
    "row_pk" text,
    "action" text not null,
    "old_data" jsonb,
    "new_data" jsonb,
    "ip" text,
    "user_agent" text
);


alter table "public"."audit_logs" enable row level security;

create table "public"."audit_row_changes" (
    "id" bigint not null default nextval('audit_row_changes_id_seq'::regclass),
    "at" timestamp with time zone not null default now(),
    "table_name" text not null,
    "action" text not null,
    "row_pk" text not null,
    "org_id" uuid,
    "actor_user_id" uuid,
    "before_data" jsonb,
    "after_data" jsonb,
    "diff" jsonb
);


create table "public"."clubs" (
    "id" uuid not null default uuid_generate_v4(),
    "name" text not null,
    "created_at" timestamp with time zone default now(),
    "org_id" uuid,
    "created_by" uuid
);


alter table "public"."clubs" enable row level security;

create table "public"."consents" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "org_id" uuid,
    "purpose" text not null,
    "version" text not null,
    "granted" boolean not null default true,
    "granted_at" timestamp with time zone not null default now(),
    "revoked_at" timestamp with time zone,
    "metadata" jsonb not null default '{}'::jsonb
);


alter table "public"."consents" enable row level security;

create table "public"."consumptions" (
    "id" uuid not null default uuid_generate_v4(),
    "player_id" uuid,
    "stick_id" uuid,
    "scanned_at" timestamp with time zone default now()
);


alter table "public"."consumptions" enable row level security;

create table "public"."dsar_audit" (
    "id" bigint not null default nextval('dsar_audit_id_seq'::regclass),
    "requested_at" timestamp with time zone not null default now(),
    "schema_name" text not null,
    "table_name" text not null,
    "record_id" text not null,
    "checksum" text not null,
    "payload" jsonb not null,
    "requested_by" text default CURRENT_USER,
    "mac_b64" text not null,
    "key_id" bigint
);


create table "public"."dsar_kms" (
    "id" bigint not null default nextval('dsar_kms_id_seq'::regclass),
    "active" boolean not null default true,
    "key_b64" text not null,
    "created_at" timestamp with time zone not null default now(),
    "rotated_at" timestamp with time zone,
    "prev_active_id" bigint
);


alter table "public"."dsar_kms" enable row level security;

create table "public"."dsar_requests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "org_id" uuid,
    "req_type" text not null,
    "status" text not null default 'open'::text,
    "payload" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "processed_at" timestamp with time zone,
    "notes" text
);


alter table "public"."dsar_requests" enable row level security;

create table "public"."feedbacks" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "org_id" uuid,
    "message" text not null,
    "rating" smallint,
    "metadata" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."feedbacks" enable row level security;

create table "public"."legal_holds" (
    "table_name" text not null,
    "row_pk" text not null,
    "reason" text,
    "placed_at" timestamp with time zone not null default now(),
    "placed_by" uuid
);


create table "public"."memberships" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "user_id" uuid not null,
    "role" org_role not null default 'player'::org_role,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."memberships" enable row level security;

create table "public"."metrics" (
    "id" bigint generated always as identity not null,
    "at" timestamp with time zone not null default now(),
    "org_id" uuid,
    "name" text not null,
    "value" numeric not null default 1,
    "dim" jsonb not null default '{}'::jsonb,
    "deleted_at" timestamp with time zone,
    "public_id" uuid default gen_random_uuid()
);


alter table "public"."metrics" enable row level security;

create table "public"."orgs" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "created_by" uuid,
    "created_at" timestamp with time zone not null default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."orgs" enable row level security;

create table "public"."players" (
    "id" uuid not null default uuid_generate_v4(),
    "email" text,
    "name" text not null,
    "club_id" uuid,
    "created_at" timestamp with time zone default now(),
    "org_id" uuid not null,
    "owner_user_id" uuid,
    "owner_id" uuid,
    "deleted_at" timestamp with time zone
);


alter table "public"."players" enable row level security;

create table "public"."privacy_requests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "request_type" text not null,
    "status" text not null default 'open'::text,
    "requested_at" timestamp with time zone not null default now(),
    "due_at" timestamp with time zone,
    "closed_at" timestamp with time zone,
    "notes" text
);


create table "public"."profiles" (
    "id" uuid not null,
    "full_name" text,
    "avatar_url" text,
    "role" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."profiles" enable row level security;

create table "public"."retention_policies" (
    "table_name" text not null,
    "keep_days" integer not null,
    "mode" text not null default 'purge'::text,
    "purge_after_days" integer default 365
);


create table "public"."rgpd_runs" (
    "run_id" bigint not null default nextval('rgpd_runs_run_id_seq'::regclass),
    "started_at" timestamp with time zone not null default now(),
    "finished_at" timestamp with time zone,
    "summary" jsonb,
    "dry_run" boolean not null default false
);


create table "public"."security_incidents" (
    "id" uuid not null default gen_random_uuid(),
    "occurred_at" timestamp with time zone not null default now(),
    "detected_at" timestamp with time zone not null default now(),
    "severity" text not null,
    "summary" text not null,
    "details" jsonb,
    "data_subjects_cnt" integer,
    "reported_to_auth" boolean default false,
    "notified_data_subj" boolean default false,
    "handled_by_user_id" uuid,
    "org_id" uuid
);


create table "public"."security_keys" (
    "name" text not null,
    "key_id" uuid,
    "deleted_at" timestamp with time zone
);


create table "public"."staff" (
    "id" uuid not null default uuid_generate_v4(),
    "email" text not null,
    "name" text not null,
    "club_id" uuid,
    "role" text default 'staff'::text,
    "created_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."staff" enable row level security;

create table "public"."sticks" (
    "id" uuid not null default uuid_generate_v4(),
    "type" text,
    "batch_code" text not null,
    "expiry_date" date,
    "created_at" timestamp with time zone default now(),
    "club_id" uuid,
    "status" stick_status not null default 'pending'::stick_status,
    "requested_by" uuid,
    "approved_by" uuid,
    "approved_at" timestamp with time zone,
    "updated_at" timestamp with time zone default now()
);


alter table "public"."sticks" enable row level security;

alter sequence "public"."audit_data_events_id_seq" owned by "public"."audit_data_events"."id";

alter sequence "public"."audit_row_changes_id_seq" owned by "public"."audit_row_changes"."id";

alter sequence "public"."dsar_audit_id_seq" owned by "public"."dsar_audit"."id";

alter sequence "public"."dsar_kms_id_seq" owned by "public"."dsar_kms"."id";

alter sequence "public"."rgpd_runs_run_id_seq" owned by "public"."rgpd_runs"."run_id";

CREATE INDEX audit_at_desc_idx ON public.audit_logs USING btree (at DESC);

CREATE UNIQUE INDEX audit_data_events_pkey ON public.audit_data_events USING btree (id);

CREATE UNIQUE INDEX audit_logs_pkey ON public.audit_logs USING btree (id);

CREATE INDEX audit_org_idx ON public.audit_logs USING btree (org_id);

CREATE UNIQUE INDEX audit_row_changes_pkey ON public.audit_row_changes USING btree (id);

CREATE INDEX audit_table_row_idx ON public.audit_logs USING btree (table_name, row_pk);

CREATE UNIQUE INDEX clubs_pkey ON public.clubs USING btree (id);

CREATE INDEX consents_org_idx ON public.consents USING btree (org_id);

CREATE UNIQUE INDEX consents_pkey ON public.consents USING btree (id);

CREATE INDEX consents_purpose_idx ON public.consents USING btree (purpose);

CREATE UNIQUE INDEX consents_uq ON public.consents USING btree (user_id, COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid), purpose, version);

CREATE INDEX consents_user_idx ON public.consents USING btree (user_id);

CREATE UNIQUE INDEX consumptions_pkey ON public.consumptions USING btree (id);

CREATE UNIQUE INDEX consumptions_player_id_stick_id_key ON public.consumptions USING btree (player_id, stick_id);

CREATE INDEX dsar_audit_checksum_idx ON public.dsar_audit USING btree (checksum);

CREATE INDEX dsar_audit_lookup_idx ON public.dsar_audit USING btree (schema_name, table_name, record_id);

CREATE UNIQUE INDEX dsar_audit_pkey ON public.dsar_audit USING btree (id);

CREATE INDEX dsar_audit_requested_at_idx ON public.dsar_audit USING btree (requested_at);

CREATE INDEX dsar_audit_schema_name_table_name_record_id_idx ON public.dsar_audit USING btree (schema_name, table_name, record_id);

CREATE INDEX dsar_kms_created_at_idx ON public.dsar_kms USING btree (created_at);

CREATE UNIQUE INDEX dsar_kms_one_active_idx ON public.dsar_kms USING btree (active) WHERE active;

CREATE UNIQUE INDEX dsar_kms_pkey ON public.dsar_kms USING btree (id);

CREATE INDEX dsar_org_idx ON public.dsar_requests USING btree (org_id);

CREATE UNIQUE INDEX dsar_requests_pkey ON public.dsar_requests USING btree (id);

CREATE INDEX dsar_status_idx ON public.dsar_requests USING btree (status);

CREATE INDEX dsar_user_idx ON public.dsar_requests USING btree (user_id);

CREATE INDEX feedbacks_at_idx ON public.feedbacks USING btree (created_at DESC);

CREATE INDEX feedbacks_org_idx ON public.feedbacks USING btree (org_id);

CREATE UNIQUE INDEX feedbacks_pkey ON public.feedbacks USING btree (id);

CREATE INDEX feedbacks_user_idx ON public.feedbacks USING btree (user_id);

CREATE INDEX idx_arc_actor ON public.audit_row_changes USING btree (actor_user_id);

CREATE INDEX idx_arc_org ON public.audit_row_changes USING btree (org_id);

CREATE INDEX idx_arc_table_at ON public.audit_row_changes USING btree (table_name, at DESC);

CREATE INDEX idx_audit_events_actor ON public.audit_data_events USING btree (actor_user_id);

CREATE INDEX idx_audit_events_org ON public.audit_data_events USING btree (org_id);

CREATE INDEX idx_audit_events_table_at ON public.audit_data_events USING btree (table_name, at DESC);

CREATE INDEX idx_clubs_org_id ON public.clubs USING btree (org_id);

CREATE INDEX idx_dsar_audit_requested_at ON public.dsar_audit USING btree (requested_at DESC);

CREATE INDEX idx_dsar_audit_table_record ON public.dsar_audit USING btree (table_name, record_id);

CREATE INDEX idx_players_org_id ON public.players USING btree (org_id);

CREATE INDEX idx_players_owner_user_id ON public.players USING btree (owner_user_id);

CREATE UNIQUE INDEX legal_holds_pkey ON public.legal_holds USING btree (table_name, row_pk);

CREATE INDEX memberships_org_id_idx ON public.memberships USING btree (org_id);

CREATE UNIQUE INDEX memberships_org_id_user_id_key ON public.memberships USING btree (org_id, user_id);

CREATE UNIQUE INDEX memberships_pkey ON public.memberships USING btree (id);

CREATE INDEX memberships_user_id_idx ON public.memberships USING btree (user_id);

CREATE UNIQUE INDEX memberships_user_org_idx ON public.memberships USING btree (user_id, org_id);

CREATE UNIQUE INDEX memberships_user_org_uidx ON public.memberships USING btree (user_id, org_id);

CREATE INDEX metrics_at_idx ON public.metrics USING btree (at DESC);

CREATE INDEX metrics_name_idx ON public.metrics USING btree (name);

CREATE INDEX metrics_org_idx ON public.metrics USING btree (org_id);

CREATE UNIQUE INDEX metrics_pkey ON public.metrics USING btree (id);

CREATE UNIQUE INDEX metrics_public_id_key ON public.metrics USING btree (public_id);

CREATE INDEX orgs_created_by_idx ON public.orgs USING btree (created_by);

CREATE UNIQUE INDEX orgs_pkey ON public.orgs USING btree (id);

CREATE UNIQUE INDEX players_email_key ON public.players USING btree (email);

CREATE INDEX players_org_id_idx ON public.players USING btree (org_id);

CREATE INDEX players_owner_idx ON public.players USING btree (owner_id);

CREATE INDEX players_owner_user_id_idx ON public.players USING btree (owner_user_id);

CREATE UNIQUE INDEX players_pkey ON public.players USING btree (id);

CREATE UNIQUE INDEX players_unique_owner_per_org ON public.players USING btree (org_id, owner_user_id) WHERE (owner_user_id IS NOT NULL);

CREATE UNIQUE INDEX privacy_requests_pkey ON public.privacy_requests USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE INDEX profiles_updated_at_idx ON public.profiles USING btree (updated_at);

CREATE UNIQUE INDEX retention_policies_pkey ON public.retention_policies USING btree (table_name);

CREATE UNIQUE INDEX rgpd_runs_pkey ON public.rgpd_runs USING btree (run_id);

CREATE UNIQUE INDEX security_incidents_pkey ON public.security_incidents USING btree (id);

CREATE UNIQUE INDEX security_keys_pkey ON public.security_keys USING btree (name);

CREATE UNIQUE INDEX staff_email_key ON public.staff USING btree (email);

CREATE UNIQUE INDEX staff_pkey ON public.staff USING btree (id);

CREATE INDEX sticks_club_id_idx ON public.sticks USING btree (club_id);

CREATE UNIQUE INDEX sticks_pkey ON public.sticks USING btree (id);

CREATE INDEX sticks_requested_by_idx ON public.sticks USING btree (requested_by);

CREATE INDEX sticks_status_idx ON public.sticks USING btree (status);

alter table "public"."audit_data_events" add constraint "audit_data_events_pkey" PRIMARY KEY using index "audit_data_events_pkey";

alter table "public"."audit_logs" add constraint "audit_logs_pkey" PRIMARY KEY using index "audit_logs_pkey";

alter table "public"."audit_row_changes" add constraint "audit_row_changes_pkey" PRIMARY KEY using index "audit_row_changes_pkey";

alter table "public"."clubs" add constraint "clubs_pkey" PRIMARY KEY using index "clubs_pkey";

alter table "public"."consents" add constraint "consents_pkey" PRIMARY KEY using index "consents_pkey";

alter table "public"."consumptions" add constraint "consumptions_pkey" PRIMARY KEY using index "consumptions_pkey";

alter table "public"."dsar_audit" add constraint "dsar_audit_pkey" PRIMARY KEY using index "dsar_audit_pkey";

alter table "public"."dsar_kms" add constraint "dsar_kms_pkey" PRIMARY KEY using index "dsar_kms_pkey";

alter table "public"."dsar_requests" add constraint "dsar_requests_pkey" PRIMARY KEY using index "dsar_requests_pkey";

alter table "public"."feedbacks" add constraint "feedbacks_pkey" PRIMARY KEY using index "feedbacks_pkey";

alter table "public"."legal_holds" add constraint "legal_holds_pkey" PRIMARY KEY using index "legal_holds_pkey";

alter table "public"."memberships" add constraint "memberships_pkey" PRIMARY KEY using index "memberships_pkey";

alter table "public"."metrics" add constraint "metrics_pkey" PRIMARY KEY using index "metrics_pkey";

alter table "public"."orgs" add constraint "orgs_pkey" PRIMARY KEY using index "orgs_pkey";

alter table "public"."players" add constraint "players_pkey" PRIMARY KEY using index "players_pkey";

alter table "public"."privacy_requests" add constraint "privacy_requests_pkey" PRIMARY KEY using index "privacy_requests_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."retention_policies" add constraint "retention_policies_pkey" PRIMARY KEY using index "retention_policies_pkey";

alter table "public"."rgpd_runs" add constraint "rgpd_runs_pkey" PRIMARY KEY using index "rgpd_runs_pkey";

alter table "public"."security_incidents" add constraint "security_incidents_pkey" PRIMARY KEY using index "security_incidents_pkey";

alter table "public"."security_keys" add constraint "security_keys_pkey" PRIMARY KEY using index "security_keys_pkey";

alter table "public"."staff" add constraint "staff_pkey" PRIMARY KEY using index "staff_pkey";

alter table "public"."sticks" add constraint "sticks_pkey" PRIMARY KEY using index "sticks_pkey";

alter table "public"."audit_data_events" add constraint "audit_data_events_action_check" CHECK ((action = ANY (ARRAY['soft_delete'::text, 'anonymize'::text, 'purge'::text]))) not valid;

alter table "public"."audit_data_events" validate constraint "audit_data_events_action_check";

alter table "public"."audit_logs" add constraint "audit_actor_user_id_auth_fkey" FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."audit_logs" validate constraint "audit_actor_user_id_auth_fkey";

alter table "public"."audit_logs" add constraint "audit_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL not valid;

alter table "public"."audit_logs" validate constraint "audit_org_id_fkey";

alter table "public"."audit_row_changes" add constraint "audit_row_changes_action_check" CHECK ((action = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text]))) not valid;

alter table "public"."audit_row_changes" validate constraint "audit_row_changes_action_check";

alter table "public"."clubs" add constraint "clubs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."clubs" validate constraint "clubs_created_by_fkey";

alter table "public"."clubs" add constraint "clubs_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE not valid;

alter table "public"."clubs" validate constraint "clubs_org_id_fkey";

alter table "public"."consents" add constraint "consents_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL not valid;

alter table "public"."consents" validate constraint "consents_org_id_fkey";

alter table "public"."consents" add constraint "consents_user_id_auth_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."consents" validate constraint "consents_user_id_auth_fkey";

alter table "public"."consumptions" add constraint "consumptions_player_id_fkey" FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE not valid;

alter table "public"."consumptions" validate constraint "consumptions_player_id_fkey";

alter table "public"."consumptions" add constraint "consumptions_player_id_stick_id_key" UNIQUE using index "consumptions_player_id_stick_id_key";

alter table "public"."consumptions" add constraint "consumptions_stick_id_fkey" FOREIGN KEY (stick_id) REFERENCES sticks(id) not valid;

alter table "public"."consumptions" validate constraint "consumptions_stick_id_fkey";

alter table "public"."dsar_audit" add constraint "dsar_audit_key_id_fkey" FOREIGN KEY (key_id) REFERENCES dsar_kms(id) not valid;

alter table "public"."dsar_audit" validate constraint "dsar_audit_key_id_fkey";

alter table "public"."dsar_requests" add constraint "dsar_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL not valid;

alter table "public"."dsar_requests" validate constraint "dsar_org_id_fkey";

alter table "public"."dsar_requests" add constraint "dsar_user_id_auth_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."dsar_requests" validate constraint "dsar_user_id_auth_fkey";

alter table "public"."feedbacks" add constraint "feedbacks_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL not valid;

alter table "public"."feedbacks" validate constraint "feedbacks_org_id_fkey";

alter table "public"."feedbacks" add constraint "feedbacks_rating_check" CHECK (((rating >= 1) AND (rating <= 5))) not valid;

alter table "public"."feedbacks" validate constraint "feedbacks_rating_check";

alter table "public"."feedbacks" add constraint "feedbacks_user_id_auth_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."feedbacks" validate constraint "feedbacks_user_id_auth_fkey";

alter table "public"."memberships" add constraint "memberships_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE not valid;

alter table "public"."memberships" validate constraint "memberships_org_id_fkey";

alter table "public"."memberships" add constraint "memberships_org_id_user_id_key" UNIQUE using index "memberships_org_id_user_id_key";

alter table "public"."memberships" add constraint "memberships_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."memberships" validate constraint "memberships_user_id_fkey";

alter table "public"."metrics" add constraint "metrics_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL not valid;

alter table "public"."metrics" validate constraint "metrics_org_id_fkey";

alter table "public"."metrics" add constraint "metrics_public_id_key" UNIQUE using index "metrics_public_id_key";

alter table "public"."orgs" add constraint "orgs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."orgs" validate constraint "orgs_created_by_fkey";

alter table "public"."players" add constraint "players_club_id_fkey" FOREIGN KEY (club_id) REFERENCES clubs(id) not valid;

alter table "public"."players" validate constraint "players_club_id_fkey";

alter table "public"."players" add constraint "players_email_key" UNIQUE using index "players_email_key";

alter table "public"."players" add constraint "players_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE not valid;

alter table "public"."players" validate constraint "players_org_id_fkey";

alter table "public"."players" add constraint "players_owner_fk" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."players" validate constraint "players_owner_fk";

alter table "public"."players" add constraint "players_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) not valid;

alter table "public"."players" validate constraint "players_owner_id_fkey";

alter table "public"."players" add constraint "players_owner_user_id_fkey" FOREIGN KEY (owner_user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."players" validate constraint "players_owner_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['coach'::text, 'athlete'::text, 'admin'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_role_check";

alter table "public"."retention_policies" add constraint "retention_policies_keep_days_check" CHECK ((keep_days >= 0)) not valid;

alter table "public"."retention_policies" validate constraint "retention_policies_keep_days_check";

alter table "public"."staff" add constraint "staff_club_id_fkey" FOREIGN KEY (club_id) REFERENCES clubs(id) not valid;

alter table "public"."staff" validate constraint "staff_club_id_fkey";

alter table "public"."staff" add constraint "staff_email_key" UNIQUE using index "staff_email_key";

alter table "public"."sticks" add constraint "sticks_club_id_fkey" FOREIGN KEY (club_id) REFERENCES clubs(id) not valid;

alter table "public"."sticks" validate constraint "sticks_club_id_fkey";

alter table "public"."sticks" add constraint "sticks_status_club_ck" CHECK ((((status = 'pending'::stick_status) AND (club_id IS NULL)) OR ((status = 'approved'::stick_status) AND (club_id IS NOT NULL)) OR ((status = 'rejected'::stick_status) AND (club_id IS NULL)))) not valid;

alter table "public"."sticks" validate constraint "sticks_status_club_ck";

alter table "public"."sticks" add constraint "sticks_type_check" CHECK ((type = ANY (ARRAY['focus'::text, 'endurance'::text, 'recovery'::text]))) not valid;

alter table "public"."sticks" validate constraint "sticks_type_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.actor_uid()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
declare v jsonb;
begin
  begin
    v := nullif(current_setting('request.jwt.claims', true),'')::jsonb;
    return (v->>'sub')::uuid;
  exception when others then
    return null;
  end;
end$function$
;

CREATE OR REPLACE FUNCTION public.dec_text(cipher bytea)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pgsodium'
AS $function$
declare
  kid   uuid;
  nonce bytea;
  ct    bytea;
  pt    bytea;
begin
  select key_id into kid from public.security_keys where name='kura_default';
  if kid is null then
    raise exception 'Encryption key not found in security_keys';
  end if;

  -- On relit le nonce (24 bytes) puis le chiffré
  nonce := substring(cipher from 1 for 24);
  ct    := substring(cipher from 25);

  pt := pgsodium.crypto_aead_det_decrypt(
          ct,
          ''::bytea,
          kid,
          nonce
        );

  return convert_from(pt, 'utf8');
end$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export(_tbl regclass, _id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  _schema text; _rel text; _sql text; _row jsonb;
begin
  select n.nspname, c.relname into _schema, _rel
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where c.oid = _tbl;

  if _schema is null then
    raise exception 'Table inconnue: %', _tbl;
  end if;

  _sql := format('select to_jsonb(t) from %I.%I t where t.id = %s::bigint', _schema, _rel, _id::text);
  execute _sql into _row;

  return jsonb_build_object(
    'schema', _schema, 'table', _rel, 'id', _id,
    'exported_at', now(), 'data', coalesce(_row, '{}'::jsonb)
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export(_tbl regclass, _id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  pk_name   text;
  pk_type   regtype;
  row_json  jsonb;
  v_schema  text;
  v_table   text;
  sql       text;
begin
  select n.nspname, c.relname
    into v_schema, v_table
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.oid = _tbl;

  select a.attname, a.atttypid::regtype
    into pk_name, pk_type
  from pg_index i
  join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any(i.indkey)
  where i.indrelid = _tbl and i.indisprimary
  limit 1;

  if pk_name is null then
    raise exception 'Aucune clé primaire détectée pour %.%', v_schema, v_table;
  end if;

  sql := format(
    'select to_jsonb(t) from %I.%I t where %I = $1::%s limit 1',
    v_schema, v_table, pk_name, pk_type::text
  );
  execute sql into row_json using _id;

  return jsonb_build_object(
    'schema',      v_schema,
    'table',       v_table,
    'pk_column',   pk_name,
    'pk_type',     pk_type::text,
    'id',          _id,
    'found',       (row_json is not null),
    'data',        coalesce(row_json, '{}'::jsonb),
    'exported_at', now()
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export(_tbl regclass, _id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  _schema text; _rel text; _sql text; _row jsonb;
begin
  select n.nspname, c.relname into _schema, _rel
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where c.oid = _tbl;

  if _schema is null then
    raise exception 'Table inconnue: %', _tbl;
  end if;

  -- on inline la valeur (évite les surprises de bind)
  _sql := format('select to_jsonb(t) from %I.%I t where t.id = %L::uuid', _schema, _rel, _id::text);
  execute _sql into _row;

  return jsonb_build_object(
    'schema', _schema, 'table', _rel, 'id', _id,
    'exported_at', now(), 'data', coalesce(_row, '{}'::jsonb)
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export_safe(tbl regclass, rec_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  pk_name     text;
  pk_type     regtype;
  row_json    jsonb;
  masked      jsonb;
  payload     jsonb;
  checksum    text;
  schema_name text;
  table_name  text;
begin
  -- détecte PK (nom + type)
  select a.attname, a.atttypid::regtype
    into pk_name, pk_type
  from pg_index i
  join pg_attribute a
    on a.attrelid = i.indrelid
   and a.attnum  = any(i.indkey)
  where i.indrelid  = tbl
    and i.indisprimary
  limit 1;

  if pk_name is null then
    raise exception 'Aucune clé primaire détectée pour %', tbl::text;
  end if;

  -- lecture sécurisée de la ligne
  execute format(
    'select to_jsonb(t) from %s t where %I = $1::%s limit 1',
    tbl::text, pk_name, pk_type::text
  )
  into row_json
  using rec_id;

  -- masque PII
  masked := public.mask_json_pii(coalesce(row_json, '{}'::jsonb));

  -- payload + checksum
  schema_name := split_part(tbl::text, '.', 1);
  table_name  := split_part(tbl::text, '.', 2);

  payload := jsonb_build_object(
    'schema',      schema_name,
    'table',       table_name,
    'pk_column',   pk_name,
    'pk_type',     pk_type::text,
    'id',          rec_id,
    'found',       (row_json is not null),
    'data',        masked,
    'exported_at', now()
  );

  checksum := public.sha256_base64(convert_to(payload::text, 'utf8'));
  payload  := payload || jsonb_build_object('checksum_sha256_b64', checksum);

  -- journal DSAR
  insert into public.dsar_audit(schema_name, table_name, record_id, checksum, payload)
  values (schema_name, table_name, rec_id, checksum, payload);

  return payload;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export_safe_hmac(_tbl regclass, _id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  pk_name  text;
  pk_type  regtype;
  row_json jsonb;
  masked   jsonb;
  v_schema text;
  v_table  text;
  out      jsonb;
begin
  -- Résolution robuste schéma/table
  select n.nspname, c.relname into v_schema, v_table
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.oid = _tbl;

  -- PK (nom + type)
  select a.attname, a.atttypid::regtype into pk_name, pk_type
  from pg_index i
  join pg_attribute a on a.attrelid=i.indrelid and a.attnum=any(i.indkey)
  where i.indrelid=_tbl and i.indisprimary
  limit 1;

  if pk_name is null then
    raise exception 'Aucune clé primaire détectée pour %.%', v_schema, v_table;
  end if;

  -- Extraction typée d’une seule ligne
  execute format('select to_jsonb(t) from %I.%I t where %I = $1::%s limit 1',
                 v_schema, v_table, pk_name, pk_type::text)
  into row_json using _id;

  masked := public.mask_json_pii_v2(coalesce(row_json, '{}'::jsonb));

  out := jsonb_build_object(
    'schema',      v_schema,
    'table',       v_table,
    'pk_column',   pk_name,
    'pk_type',     pk_type::text,
    'id',          _id,
    'found',       (row_json is not null),
    'data',        masked,
    'exported_at', now()
  );

  -- Signe le payload (HMAC) et ajoute la signature
  out := out || jsonb_build_object('mac_hs256_b64', public.hmac256_jsonb_b64(out));
  return out;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export_safe_hmac_log(_tbl regclass, _id text)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_schema text;
  v_table  text;
  out      jsonb;
begin
  select n.nspname, c.relname into v_schema, v_table
  from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where c.oid=_tbl;

  out := public.dsar_export_safe_hmac(_tbl, _id);

  -- INSERT : le trigger calcule mac_b64 automatiquement
  insert into public.dsar_audit(schema_name, table_name, record_id, payload)
  values (v_schema, v_table, _id, out);

  return out;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_export_safe_log(tbl regclass, rec_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  out_payload jsonb;
  checksum    text;
  schema_name text;
  table_name  text;
begin
  select n.nspname, c.relname
    into schema_name, table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.oid = tbl;

  out_payload := public.dsar_export_safe(tbl, rec_id);
  checksum := out_payload->>'checksum_sha256_b64';

  insert into public.dsar_audit(schema_name, table_name, record_id, checksum, payload)
  values (schema_name, table_name, rec_id, checksum, out_payload);

  return out_payload;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_get_hmac_key_b64()
 RETURNS text
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select key_b64 from public.dsar_kms where active limit 1
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_rotate_hmac_key()
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
declare
  v_old_id bigint;
  v_new_id bigint;
begin
  -- 1) Clé active actuelle
  select id into v_old_id
  from public.dsar_kms
  where active
  limit 1;

  if v_old_id is null then
    raise exception 'No active key found in dsar_kms';
  end if;

  -- 2) Désactive l’ancienne clé
  update public.dsar_kms
     set active = false,
         rotated_at = now()
   where id = v_old_id;

  -- 3) Insère la nouvelle clé (32 octets → base64)
  insert into public.dsar_kms (key_b64, active, created_at, prev_active_id)
  values (
    encode(gen_random_bytes(32), 'base64'),
    true,
    now(),
    v_old_id
  )
  returning id into v_new_id;

  -- 4) Laisse le trigger "exactly one active" valider en fin de txn
  perform null;

  return v_new_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_verify(checksum text, payload jsonb)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
  -- Enlève la clé 'checksum_sha256_b64' avant de recalculer le SHA-256
  select checksum = public.sha256_base64(
           convert_to( (payload - 'checksum_sha256_b64')::text, 'utf8')
         );
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_verify_hmac(_mac_b64 text, _payload jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return public.hmac256_jsonb_b64(_payload) = _mac_b64;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.dsar_verify_hmac_with_key(_key_b64 text, _mac_b64 text, _payload jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  calc text;
begin
  calc := public.hmac256_jsonb_b64_with_key(_key_b64, _payload);
  return calc = _mac_b64;  -- comparaison simple (OK ici)
end;
$function$
;

CREATE OR REPLACE FUNCTION public.enc_text(plain text)
 RETURNS bytea
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pgsodium'
AS $function$
declare
  kid   uuid;
  nonce bytea;
  ct    bytea;
begin
  select key_id into kid from public.security_keys where name='kura_default';
  if kid is null then
    raise exception 'Encryption key not found in security_keys';
  end if;

  -- 24 octets de nonce (généré) ; on le préfixe au chiffré
  nonce := pgsodium.randombytes_buf(24);

  ct := pgsodium.crypto_aead_det_encrypt(
          plain::bytea,
          ''::bytea,
          kid,
          nonce
        );

  return nonce || ct;
end$function$
;

CREATE OR REPLACE FUNCTION public.ensure_org_has_admin()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  target_org uuid;
  remaining_admins integer;
begin
  if TG_OP = 'DELETE' then
    -- si on supprime un membership non-admin, OK
    if OLD.role <> 'admin' then
      return OLD;
    end if;

    target_org := OLD.org_id;

    -- combien d'admins resteraient après suppression ?
    select count(*) into remaining_admins
    from public.memberships
    where org_id = target_org
      and role = 'admin'
      and user_id <> OLD.user_id;

    if remaining_admins < 1 then
      raise exception 'Operation would remove the last admin of the organization (%).', target_org
        using errcode = 'P0001';
    end if;

    return OLD;

  elsif TG_OP = 'UPDATE' then
    -- si on retire le rôle admin (ou on déplace l'admin vers une autre org)
    if OLD.role = 'admin' and (NEW.role <> 'admin' or NEW.org_id <> OLD.org_id) then
      target_org := OLD.org_id;

      select count(*) into remaining_admins
      from public.memberships
      where org_id = target_org
        and role = 'admin'
        and user_id <> OLD.user_id;

      if remaining_admins < 1 then
        raise exception 'Operation would leave organization (%) without any admin.', target_org
          using errcode = 'P0001';
      end if;
    end if;

    return NEW;
  end if;

  return coalesce(NEW, OLD);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_metrics(p_id bigint)
 RETURNS void
 LANGUAGE sql
AS $function$
        update public.metrics
           set name      = concat('anon_', left(md5((id::text)||now()::text), 8))
         where id = p_id;
      $function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_metrics(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='metrics') then
    perform public.fn_anonymize_row('public.metrics'::regclass, p_id);
  end if;
end$function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_orgs(p_id uuid)
 RETURNS void
 LANGUAGE sql
AS $function$
        update public.orgs
           set name      = concat('anon_', left(md5((id::text)||now()::text), 8))
         where id = p_id;
      $function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_player(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='players') then
    perform public.fn_anonymize_row('public.players'::regclass, p_id);
  end if;
end$function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_profiles(p_id uuid)
 RETURNS void
 LANGUAGE sql
AS $function$
        update public.profiles
           set full_name = concat('anon_', left(md5((id::text)||now()::text), 8))
         where id = p_id;
      $function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_row(_table regclass, _id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  cols record;
  sets text := '';
  sep  text := '';
  sql  text;
  has_email bool := false;
begin
  -- Parcours des colonnes existantes et construit dynamiquement un SET
  for cols in
    select column_name, data_type
    from information_schema.columns
    where table_schema = split_part(_table::text, '.', 1)
      and table_name   = split_part(_table::text, '.', 2)
  loop
    -- e-mail
    if cols.column_name ilike '%email%' then
      has_email := true;
      sets := sets || sep || format('%I = concat(''anon+'', left(md5((id::text)||now()::text),12), ''@example.com'')', cols.column_name);
      sep := ', ';
    -- noms
    elsif cols.column_name in ('name','full_name','first_name','last_name','display_name') then
      sets := sets || sep || format('%I = NULL', cols.column_name);
      sep := ', ';
    -- téléphone
    elsif cols.column_name in ('phone','phone_number','mobile') then
      sets := sets || sep || format('%I = NULL', cols.column_name);
      sep := ', ';
    -- adresse
    elsif cols.column_name in ('address','address_line1','address_line2','city','zip','postal_code','country') then
      sets := sets || sep || format('%I = NULL', cols.column_name);
      sep := ', ';
    -- date de naissance
    elsif cols.column_name in ('birthdate','dob','date_of_birth','birth_year') then
      sets := sets || sep || format('%I = NULL', cols.column_name);
      sep := ', ';
    -- identifiants/ips éventuels
    elsif cols.column_name in ('ip','last_login_ip','session_token','national_id','ssn') then
      sets := sets || sep || format('%I = NULL', cols.column_name);
      sep := ', ';
    end if;
  end loop;

  -- Si aucune colonne PII détectée, ne fait rien
  if sets = '' then
    return;
  end if;

  -- Construit l’UPDATE final
  sql := format('update %s set %s where id = $1', _table::text, sets);
  execute sql using _id;
end
$function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_security_keys(p_id text)
 RETURNS void
 LANGUAGE sql
AS $function$
        update public.security_keys
           set name      = concat('anon_', left(md5((name::text)||now()::text), 8))
         where name = p_id;
      $function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_security_keys(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='security_keys') then
    perform public.fn_anonymize_row('public.security_keys'::regclass, p_id);
  end if;
end$function$
;

CREATE OR REPLACE FUNCTION public.fn_anonymize_staff(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='staff') then
    perform public.fn_anonymize_row('public.staff'::regclass, p_id);
  end if;
end$function$
;

CREATE OR REPLACE FUNCTION public.fn_audit_row_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_action text := TG_OP;            -- 'INSERT' | 'UPDATE' | 'DELETE'
  v_table  text := TG_TABLE_NAME;
  v_actor  uuid := public.actor_uid();
  v_before jsonb;
  v_after  jsonb;
  v_org_id uuid;
  v_pk     text;                     -- suppose une PK 'id' (uuid/bigint)
  v_diff   jsonb;
begin
  -- États avant/après
  if v_action = 'INSERT' then
    v_before := null;
    v_after  := to_jsonb(NEW);
  elsif v_action = 'UPDATE' then
    v_before := to_jsonb(OLD);
    v_after  := to_jsonb(NEW);
  else
    v_before := to_jsonb(OLD);
    v_after  := null;
  end if;

  -- PK (id puis fallback public_id)
  v_pk := coalesce(
           case when v_action in ('UPDATE','DELETE') then v_before->>'id' end,
           case when v_action in ('INSERT','UPDATE') then v_after->>'id'  end,
           case when v_action in ('UPDATE','DELETE') then v_before->>'public_id' end,
           case when v_action in ('INSERT','UPDATE') then v_after->>'public_id'  end,
           gen_random_uuid()::text
         );

  -- org_id si présent
  v_org_id := coalesce(
               case when v_action in ('UPDATE','DELETE') then (v_before->>'org_id')::uuid end,
               case when v_action in ('INSERT','UPDATE') then (v_after->>'org_id')::uuid  end,
               null
             );

  -- Diff uniquement pour UPDATE
  if v_action = 'UPDATE' then
    v_diff := public.jsonb_diff_after(v_before, v_after);
  else
    v_diff := null;
  end if;

  insert into public.audit_row_changes(
    table_name, action, row_pk, org_id, actor_user_id,
    before_data, after_data, diff
  )
  values (
    v_table, v_action, v_pk, v_org_id, v_actor,
    v_before, v_after, v_diff
  );

  return null; -- AFTER trigger
end$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''));
  return new;
end; $function$
;

CREATE OR REPLACE FUNCTION public.has_org_role(p_org_id uuid, p_roles org_role[])
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.org_id = p_org_id
      and m.user_id = auth.uid()
      and m.role = any(p_roles)
  );
$function$
;

CREATE OR REPLACE FUNCTION public.hmac256_jsonb_b64(_j jsonb)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  k_b64 text;
  mac   bytea;
begin
  k_b64 := public.dsar_get_hmac_key_b64();
  mac := hmac(convert_to(_j::text,'utf8'), decode(k_b64,'base64'), 'sha256');
  return encode(mac,'base64');
end;
$function$
;

CREATE OR REPLACE FUNCTION public.hmac256_jsonb_b64_with_key(_key_b64 text, _payload jsonb)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  mac bytea;
begin
  mac := hmac(convert_to(_payload::text,'utf8'), decode(_key_b64,'base64'), 'sha256');
  return encode(mac,'base64');
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_admin(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select public.is_org_role(p_org_id, array['admin'::public.org_role]);
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_admin_or_coach(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select public.has_org_role(p_org_id, array['admin','coach']::org_role[]);
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_member(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.org_id = p_org_id
      and m.user_id = auth.uid()
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_role(p_org_id uuid, p_roles org_role[])
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.org_id = p_org_id
      and m.user_id = auth.uid()
      and m.role = any(p_roles)   -- aucun cast texte, on reste en enum
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_role(p_org_id uuid, p_roles text[])
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.org_id = p_org_id
      and m.user_id = auth.uid()
      and m.role::text = any (p_roles)   -- 👈 cast enum -> text
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_staff_or_admin(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists(
    select 1
    from public.memberships m
    where m.org_id = p_org_id
      and m.user_id = auth.uid()
      and m.role = any (array['admin','staff']::org_role[])
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_rgpd_operator(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.user_id = auth.uid()
      and m.org_id  = p_org_id
      and m.role in ('dpo','rgpd_manager','admin')  -- admin inclus par design
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_staff_or_admin(p_org_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1
    from public.memberships m
    where m.user_id = auth.uid()
      and m.org_id  = p_org_id
      and m.role in ('admin','staff','med','dpo','rgpd_manager')
  );
$function$
;

CREATE OR REPLACE FUNCTION public.jsonb_diff_after(old jsonb, new jsonb)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$
with keys as (
  select coalesce(a.key, b.key) as k,
         a.value                as old_v,
         b.value                as new_v
  from jsonb_each(coalesce(old,'{}'::jsonb)) a
  full join jsonb_each(coalesce(new,'{}'::jsonb)) b
    on a.key = b.key
)
select coalesce(
  jsonb_object_agg(k, new_v) filter (where new_v is distinct from old_v),
  '{}'::jsonb
)
from keys;
$function$
;

CREATE OR REPLACE FUNCTION public.mask_json_pii(j jsonb)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select jsonb_object_agg(k,
           case lower(k)
             when 'email'      then to_jsonb('***@***'::text)
             when 'name'       then to_jsonb('REDACTED'::text)
             when 'full_name'  then to_jsonb('REDACTED'::text)
             when 'first_name' then to_jsonb('REDACTED'::text)
             when 'last_name'  then to_jsonb('REDACTED'::text)
             when 'phone'      then to_jsonb('********'::text)
             when 'address'    then to_jsonb('REDACTED'::text)
             else v
           end)
  from jsonb_each(coalesce(j,'{}'::jsonb)) t(k,v);
$function$
;

CREATE OR REPLACE FUNCTION public.mask_json_pii_v2(j jsonb)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$
  with root as (
    select jsonb_object_agg(k,
             case lower(k)
               when 'email'      then to_jsonb('***@***'::text)
               when 'name'       then to_jsonb('REDACTED'::text)
               when 'full_name'  then to_jsonb('REDACTED'::text)
               when 'first_name' then to_jsonb('REDACTED'::text)
               when 'last_name'  then to_jsonb('REDACTED'::text)
               when 'phone'      then to_jsonb('********'::text)
               when 'address'    then to_jsonb('REDACTED'::text)
               else v
             end)
    from jsonb_each(coalesce(j,'{}'::jsonb)) t(k,v)
  )
  select case
           when (j ? 'dim') then jsonb_set(root.jsonb_object_agg, '{dim}',
                 (select jsonb_object_agg(k,
                           case lower(k)
                             when 'email' then to_jsonb('***@***'::text)
                             when 'name'  then to_jsonb('REDACTED'::text)
                             else v end)
                  from jsonb_each(coalesce(j->'dim','{}'::jsonb)) t(k,v)
                 ), true)
           else root.jsonb_object_agg
         end
  from root
$function$
;

CREATE OR REPLACE FUNCTION public.mask_text_pii(_t text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
select coalesce(
  regexp_replace(
    regexp_replace(
      regexp_replace(
        regexp_replace(
          regexp_replace(_t, public.re_email(), '\1@***.***', 'gi'),
        public.re_phone(), '(***) *** ** **', 'gi'),
      public.re_iban(), '****IBAN****', 'gi'),
    public.re_card(), '****CARD****', 'gi'),
  public.re_ssn(),  '****SSN****',  'gi'
  ),
  _t
);
$function$
;

create or replace view "public"."metrics_public" as  SELECT public_id,
    org_id,
    name,
    value,
    at,
    dim
   FROM metrics;


CREATE OR REPLACE FUNCTION public.purge_retention()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  r record;
begin
  for r in select * from public.retention_policies loop

    -- ===== players =====
    if r.table_name = 'players' and r.mode = 'anonymize' then
      perform public.fn_anonymize_player(p.id)
      from public.players p
      where p.deleted_at is not null
        and p.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.players p
      where p.deleted_at is not null
        and p.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== staff =====
    elsif r.table_name = 'staff' and r.mode = 'anonymize' then
      perform public.fn_anonymize_staff(s.id)
      from public.staff s
      where s.deleted_at is not null
        and s.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.staff s
      where s.deleted_at is not null
        and s.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== metrics =====
    elsif r.table_name = 'metrics' and r.mode = 'anonymize' then
      perform public.fn_anonymize_metrics(m.id)
      from public.metrics m
      where m.deleted_at is not null
        and m.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.metrics m
      where m.deleted_at is not null
        and m.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== orgs =====
    elsif r.table_name = 'orgs' and r.mode = 'anonymize' then
      perform public.fn_anonymize_orgs(o.id)
      from public.orgs o
      where o.deleted_at is not null
        and o.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.orgs o
      where o.deleted_at is not null
        and o.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== profiles =====
    elsif r.table_name = 'profiles' and r.mode = 'anonymize' then
      perform public.fn_anonymize_profiles(pf.id)
      from public.profiles pf
      where pf.deleted_at is not null
        and pf.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.profiles pf
      where pf.deleted_at is not null
        and pf.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== security_keys (si tu veux vraiment nettoyer aussi) =====
    elsif r.table_name = 'security_keys' and r.mode = 'anonymize' then
      perform public.fn_anonymize_security_keys(sk.name)  -- wrapper ignore la valeur, c'est OK
      from public.security_keys sk
      where sk.deleted_at is not null
        and sk.deleted_at < now() - (r.keep_days || ' days')::interval;

      delete from public.security_keys sk
      where sk.deleted_at is not null
        and sk.deleted_at < now() - (r.keep_days || ' days')::interval;

    -- ===== mode = 'purge' (supprime direct tout soft-deleted) =====
    elsif r.mode = 'purge' then
      execute format(
        'delete from public.%I where deleted_at is not null and deleted_at < now() - (%L || '' days'')::interval',
        r.table_name, r.keep_days::text
      );
    end if;

  end loop;
end$function$
;

CREATE OR REPLACE FUNCTION public.re_card()
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select '\b(?:\d[ -]*?){13,19}\b' $function$
;

CREATE OR REPLACE FUNCTION public.re_email()
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select '([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})' $function$
;

CREATE OR REPLACE FUNCTION public.re_iban()
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select '\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b' $function$
;

CREATE OR REPLACE FUNCTION public.re_phone()
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select '(\+?\d[\d\-\s().]{7,}\d)' $function$
;

CREATE OR REPLACE FUNCTION public.re_ssn()
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  -- générique (US/EU), volontairement large
  select '\b\d{3}[-\s]?\d{2}[-\s]?\d{4}\b|\b\d{2}[-\s]?\d{2}[-\s]?\d{2}[-\s]?\d{3}\b' $function$
;

create or replace view "public"."rgpd_report_last30" as  SELECT table_name,
    action,
    count(*) AS rows_affected,
    min(at) AS first_event_at,
    max(at) AS last_event_at
   FROM audit_data_events ae
  WHERE (at >= (now() - '30 days'::interval))
  GROUP BY table_name, action
  ORDER BY (max(at)) DESC;


CREATE OR REPLACE FUNCTION public.run_rgpd_maintenance()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  r            record;
  run_key      bigint;
  _actor       uuid := public.actor_uid();
  _summary     jsonb := '{}'::jsonb;

  _count_anon  int;
  _count_purge int;
begin
  insert into public.rgpd_runs default values returning run_id into run_key;

  for r in
    select table_name, keep_days, mode
    from public.retention_policies
    order by table_name
  loop
    -- traiter seulement les tables qui ont deleted_at
    if not exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name=r.table_name and column_name='deleted_at'
    ) then
      continue;
    end if;

    _count_anon  := 0;
    _count_purge := 0;

    -- ===== metrics (id bigint, org_id uuid) =====
    if r.table_name = 'metrics' then
      if r.mode = 'anonymize' then
        perform public.fn_anonymize_metrics(c.id)
        from (
          select m.id
          from public.metrics m
          where m.deleted_at is not null
            and m.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;

        GET DIAGNOSTICS _count_anon = ROW_COUNT;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'metrics','anonymize', c.id::text, c.org_id, _actor,
               jsonb_build_object('run_id', run_key)
        from (
          select m.id, m.org_id
          from public.metrics m
          where m.deleted_at is not null
            and m.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;
      end if;

      with purged as (
        delete from public.metrics m
        where m.deleted_at is not null
          and m.deleted_at < now() - make_interval(days => r.keep_days)
        returning m.id::text as row_pk, m.org_id
      )
      insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
      select 'metrics','purge', p.row_pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
      from purged p;

      GET DIAGNOSTICS _count_purge = ROW_COUNT;

    -- ===== players (id uuid) =====
    elsif r.table_name = 'players' then
      if r.mode = 'anonymize' then
        perform public.fn_anonymize_player(c.id)
        from (
          select p.id
          from public.players p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;

        GET DIAGNOSTICS _count_anon = ROW_COUNT;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'players','anonymize', c.id::text, null::uuid, _actor,
               jsonb_build_object('run_id', run_key)
        from (
          select p.id
          from public.players p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;
      end if;

      with purged as (
        delete from public.players p
        where p.deleted_at is not null
          and p.deleted_at < now() - make_interval(days => r.keep_days)
        returning p.id::text as row_pk, null::uuid as org_id
      )
      insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
      select 'players','purge', p.row_pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
      from purged p;

      GET DIAGNOSTICS _count_purge = ROW_COUNT;

    -- ===== staff (id uuid) =====
    elsif r.table_name = 'staff' then
      if r.mode = 'anonymize' then
        perform public.fn_anonymize_staff(c.id)
        from (
          select s.id
          from public.staff s
          where s.deleted_at is not null
            and s.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;

        GET DIAGNOSTICS _count_anon = ROW_COUNT;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'staff','anonymize', c.id::text, null::uuid, _actor,
               jsonb_build_object('run_id', run_key)
        from (
          select s.id
          from public.staff s
          where s.deleted_at is not null
            and s.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;
      end if;

      with purged as (
        delete from public.staff s
        where s.deleted_at is not null
          and s.deleted_at < now() - make_interval(days => r.keep_days)
        returning s.id::text as row_pk, null::uuid as org_id
      )
      insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
      select 'staff','purge', p.row_pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
      from purged p;

      GET DIAGNOSTICS _count_purge = ROW_COUNT;

    -- ===== profiles (id uuid) =====
    elsif r.table_name = 'profiles' then
      if r.mode = 'anonymize' then
        perform public.fn_anonymize_profiles(c.id)
        from (
          select p.id
          from public.profiles p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;

        GET DIAGNOSTICS _count_anon = ROW_COUNT;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'profiles','anonymize', c.id::text, null::uuid, _actor,
               jsonb_build_object('run_id', run_key)
        from (
          select p.id
          from public.profiles p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;
      end if;

      with purged as (
        delete from public.profiles p
        where p.deleted_at is not null
          and p.deleted_at < now() - make_interval(days => r.keep_days)
        returning p.id::text as row_pk, null::uuid as org_id
      )
      insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
      select 'profiles','purge', p.row_pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
      from purged p;

      GET DIAGNOSTICS _count_purge = ROW_COUNT;

    -- ===== orgs (id uuid) =====
    elsif r.table_name = 'orgs' then
      if r.mode = 'anonymize' then
        perform public.fn_anonymize_orgs(c.id)
        from (
          select o.id
          from public.orgs o
          where o.deleted_at is not null
            and o.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;

        GET DIAGNOSTICS _count_anon = ROW_COUNT;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'orgs','anonymize', c.id::text, null::uuid, _actor,
               jsonb_build_object('run_id', run_key)
        from (
          select o.id
          from public.orgs o
          where o.deleted_at is not null
            and o.deleted_at < now() - make_interval(days => r.keep_days)
        ) as c;
      end if;

      with purged as (
        delete from public.orgs o
        where o.deleted_at is not null
          and o.deleted_at < now() - make_interval(days => r.keep_days)
        returning o.id::text as row_pk, null::uuid as org_id
      )
      insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
      select 'orgs','purge', p.row_pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
      from purged p;

      GET DIAGNOSTICS _count_purge = ROW_COUNT;

    end if;

    _summary := _summary || jsonb_build_object(
      r.table_name, jsonb_build_object(
        'mode', r.mode,
        'anonymized', coalesce(_count_anon,0),
        'purged',     coalesce(_count_purge,0)
      )
    );
  end loop;

  update public.rgpd_runs
     set finished_at = now(),
         summary     = _summary
   where run_id = run_key;
end$function$
;

CREATE OR REPLACE FUNCTION public.run_rgpd_maintenance(_dry_run boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  r record;
  run_key bigint;
  _actor uuid := public.actor_uid();           -- peut être NULL si non authentifié
  _sum jsonb := '{}'::jsonb;
  _an int;                                     -- nb anonymisés dans l’itération
  _pg int;                                     -- nb purgés dans l’itération
begin
  -- 1) tracer le démarrage du run
  insert into public.rgpd_runs(dry_run, started_at)
  values (_dry_run, now())
  returning run_id into run_key;

  -- 2) parcourir les politiques
  for r in
    select table_name, keep_days, mode
    from public.retention_policies
    order by table_name
  loop
    -- ignorer si pas de deleted_at
    if not exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name=r.table_name and column_name='deleted_at'
    ) then
      continue;
    end if;

    _an := 0; _pg := 0;

    -- =============== METRICS (id bigint, org_id uuid) =======================
    if r.table_name = 'metrics' then
      -- anonymisation
      if r.mode = 'anonymize' and not _dry_run then
        perform public.fn_anonymize_metrics(m.id)
        from public.metrics m
        where m.deleted_at is not null
          and m.deleted_at < now() - make_interval(days => r.keep_days)
          and not exists (
            select 1 from public.legal_holds h
            where h.table_name='metrics' and h.row_pk = m.id::text
          );
        get diagnostics _an = row_count;

        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'metrics','anonymize', m.id::text, m.org_id, _actor,
               jsonb_build_object('run_id', run_key)
        from public.metrics m
        where m.deleted_at is not null
          and m.deleted_at < now() - make_interval(days => r.keep_days)
          and not exists (
            select 1 from public.legal_holds h
            where h.table_name='metrics' and h.row_pk = m.id::text
          );
      end if;

      -- purge (avec audit via RETURNING)
      if not _dry_run then
        with purged as (
          delete from public.metrics m
          where m.deleted_at is not null
            and m.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='metrics' and h.row_pk = m.id::text
            )
          returning m.id::text as pk, m.org_id
        )
        insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
        select 'metrics','purge', p.pk, p.org_id, _actor, jsonb_build_object('run_id', run_key)
        from purged p;
        get diagnostics _pg = row_count;
      else
        select count(*)
          into _pg
        from public.metrics m
        where m.deleted_at is not null
          and m.deleted_at < now() - make_interval(days => r.keep_days)
          and not exists (
            select 1 from public.legal_holds h
            where h.table_name='metrics' and h.row_pk = m.id::text
          );
      end if;

    -- ========== PLAYERS / STAFF / PROFILES / ORGS (id uuid) ================
    elsif r.table_name in ('players','staff','profiles','orgs') then
      -- anonymisation (dynamiquement, en appelant la bonne fonction)
      if r.mode = 'anonymize' and not _dry_run then
        if r.table_name = 'players' then
          perform public.fn_anonymize_player(p.id)
          from public.players p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='players' and h.row_pk = p.id::text
            );

          get diagnostics _an = row_count;

          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'players','anonymize', p.id::text, null::uuid, _actor,
                 jsonb_build_object('run_id', run_key)
          from public.players p
          where p.deleted_at is not null
            and p.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='players' and h.row_pk = p.id::text
            );

        elsif r.table_name = 'staff' then
          perform public.fn_anonymize_staff(s.id)
          from public.staff s
          where s.deleted_at is not null
            and s.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='staff' and h.row_pk = s.id::text
            );

          get diagnostics _an = row_count;

          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'staff','anonymize', s.id::text, null::uuid, _actor,
                 jsonb_build_object('run_id', run_key)
          from public.staff s
          where s.deleted_at is not null
            and s.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='staff' and h.row_pk = s.id::text
            );

        elsif r.table_name = 'profiles' then
          perform public.fn_anonymize_profiles(pf.id)
          from public.profiles pf
          where pf.deleted_at is not null
            and pf.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='profiles' and h.row_pk = pf.id::text
            );

          get diagnostics _an = row_count;

          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'profiles','anonymize', pf.id::text, null::uuid, _actor,
                 jsonb_build_object('run_id', run_key)
          from public.profiles pf
          where pf.deleted_at is not null
            and pf.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='profiles' and h.row_pk = pf.id::text
            );

        elsif r.table_name = 'orgs' then
          perform public.fn_anonymize_orgs(o.id)
          from public.orgs o
          where o.deleted_at is not null
            and o.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='orgs' and h.row_pk = o.id::text
            );

          get diagnostics _an = row_count;

          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'orgs','anonymize', o.id::text, null::uuid, _actor,
                 jsonb_build_object('run_id', run_key)
          from public.orgs o
          where o.deleted_at is not null
            and o.deleted_at < now() - make_interval(days => r.keep_days)
            and not exists (
              select 1 from public.legal_holds h
              where h.table_name='orgs' and h.row_pk = o.id::text
            );
        end if;
      end if;

      -- purge (avec audit via RETURNING)
      if not _dry_run then
        if r.table_name = 'players' then
          with purged as (
            delete from public.players p
            where p.deleted_at is not null
              and p.deleted_at < now() - make_interval(days => r.keep_days)
              and not exists (
                select 1 from public.legal_holds h
                where h.table_name='players' and h.row_pk = p.id::text
              )
            returning p.id::text as pk
          )
          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'players','purge', pk, null::uuid, _actor, jsonb_build_object('run_id', run_key)
          from purged;
          get diagnostics _pg = row_count;

        elsif r.table_name = 'staff' then
          with purged as (
            delete from public.staff s
            where s.deleted_at is not null
              and s.deleted_at < now() - make_interval(days => r.keep_days)
              and not exists (
                select 1 from public.legal_holds h
                where h.table_name='staff' and h.row_pk = s.id::text
              )
            returning s.id::text as pk
          )
          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'staff','purge', pk, null::uuid, _actor, jsonb_build_object('run_id', run_key)
          from purged;
          get diagnostics _pg = row_count;

        elsif r.table_name = 'profiles' then
          with purged as (
            delete from public.profiles pf
            where pf.deleted_at is not null
              and pf.deleted_at < now() - make_interval(days => r.keep_days)
              and not exists (
                select 1 from public.legal_holds h
                where h.table_name='profiles' and h.row_pk = pf.id::text
              )
            returning pf.id::text as pk
          )
          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'profiles','purge', pk, null::uuid, _actor, jsonb_build_object('run_id', run_key)
          from purged;
          get diagnostics _pg = row_count;

        elsif r.table_name = 'orgs' then
          with purged as (
            delete from public.orgs o
            where o.deleted_at is not null
              and o.deleted_at < now() - make_interval(days => r.keep_days)
              and not exists (
                select 1 from public.legal_holds h
                where h.table_name='orgs' and h.row_pk = o.id::text
              )
            returning o.id::text as pk
          )
          insert into public.audit_data_events(table_name, action, row_pk, org_id, actor_user_id, details)
          select 'orgs','purge', pk, null::uuid, _actor, jsonb_build_object('run_id', run_key)
          from purged;
          get diagnostics _pg = row_count;
        end if;

      else
        -- dry-run : simple comptage des candidats à purge
        execute format(
          'select count(*) from public.%I t where t.deleted_at is not null and t.deleted_at < now() - make_interval(days => %s)',
          r.table_name, r.keep_days
        ) into _pg;
      end if;
    end if;

    -- agrégation dans le résumé
    _sum := _sum || jsonb_build_object(
      r.table_name, jsonb_build_object(
        'mode', r.mode,
        'anonymized', coalesce(_an,0),
        'purged',     coalesce(_pg,0)
      )
    );
  end loop;

  -- 3) clore le run
  update public.rgpd_runs
     set finished_at = now(),
         summary     = _sum
   where run_id = run_key;
end$function$
;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end$function$
;

CREATE OR REPLACE FUNCTION public.sha256_base64(_b bytea)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ select encode(digest(_b,'sha256'),'base64') $function$
;

CREATE OR REPLACE FUNCTION public.sticks_approve(p_stick_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_org uuid;
begin
  -- L’org du staff qui approuve (coach/admin)
  select m.org_id
    into v_org
    from public.memberships m
   where m.user_id = auth.uid()
     and m.role in ('admin','coach')
   limit 1;

  if v_org is null then
    raise exception 'Only admin/coach can approve';
  end if;

  update public.sticks
     set status   = 'approved',
         club_id  = v_org,
         updated_at = now()
   where id = p_stick_id
     and status = 'pending';

  if not found then
    raise exception 'Stick not in pending or not found';
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.sticks_reject(p_stick_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  -- On ne touche que si le stick est encore en pending
  update public.sticks
     set status   = 'rejected',
         -- club_id reste NULL si c'était NULL
         updated_at = now()
   where id = p_stick_id
     and status = 'pending';

  if not found then
    raise exception 'Stick not in pending or not found';
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.sticks_set_club_id()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_org uuid;
begin
  -- On n’auto-remplit le club QUE quand le stick passe à "approved"
  if (TG_OP = 'INSERT' or TG_OP = 'UPDATE')
     and new.status = 'approved'
     and new.club_id is null then

    -- on récupère le club du coach/admin courant
    select m.org_id
      into v_org
    from public.memberships m
    where m.user_id = auth.uid()
      and m.role in ('admin','coach')
    limit 1;

    if v_org is null then
      raise exception 'Aucun club (coach/admin) pour l’utilisateur courant — renseigne club_id explicitement';
    end if;

    new.club_id := v_org;
  end if;

  return new;
end
$function$
;

CREATE OR REPLACE FUNCTION public.trg_dsar_audit_mac()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_key_id bigint;
begin
  select id into v_key_id from public.dsar_kms where active limit 1;
  new.key_id := v_key_id;
  new.mac_b64 := public.hmac256_jsonb_b64(new.payload);
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.trg_dsar_kms_exactly_one_active()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  -- at least one
  if not exists (select 1 from public.dsar_kms where active) then
    raise exception 'There must be at least one active key in dsar_kms';
  end if;

  -- no more than one (index already prevents this, but double-check)
  if (select count(*) from public.dsar_kms where active) > 1 then
    raise exception 'More than one active key in dsar_kms';
  end if;

  return null; -- AFTER row-level constraint trigger → return value ignored
end;
$function$
;

create or replace view "public"."dsar_audit_verify" as  SELECT id,
    requested_at,
    schema_name,
    table_name,
    record_id,
    (NOT dsar_verify_hmac(mac_b64, payload)) AS invalid_current_key,
    (NOT dsar_verify_hmac_with_key(( SELECT k.key_b64
           FROM dsar_kms k
          WHERE (k.id = a.key_id)), mac_b64, payload)) AS invalid_original_key
   FROM dsar_audit a;


grant delete on table "public"."audit_data_events" to "anon";

grant insert on table "public"."audit_data_events" to "anon";

grant references on table "public"."audit_data_events" to "anon";

grant select on table "public"."audit_data_events" to "anon";

grant trigger on table "public"."audit_data_events" to "anon";

grant truncate on table "public"."audit_data_events" to "anon";

grant update on table "public"."audit_data_events" to "anon";

grant delete on table "public"."audit_data_events" to "authenticated";

grant insert on table "public"."audit_data_events" to "authenticated";

grant references on table "public"."audit_data_events" to "authenticated";

grant select on table "public"."audit_data_events" to "authenticated";

grant trigger on table "public"."audit_data_events" to "authenticated";

grant truncate on table "public"."audit_data_events" to "authenticated";

grant update on table "public"."audit_data_events" to "authenticated";

grant delete on table "public"."audit_data_events" to "service_role";

grant insert on table "public"."audit_data_events" to "service_role";

grant references on table "public"."audit_data_events" to "service_role";

grant select on table "public"."audit_data_events" to "service_role";

grant trigger on table "public"."audit_data_events" to "service_role";

grant truncate on table "public"."audit_data_events" to "service_role";

grant update on table "public"."audit_data_events" to "service_role";

grant references on table "public"."audit_logs" to "anon";

grant select on table "public"."audit_logs" to "anon";

grant trigger on table "public"."audit_logs" to "anon";

grant truncate on table "public"."audit_logs" to "anon";

grant references on table "public"."audit_logs" to "authenticated";

grant select on table "public"."audit_logs" to "authenticated";

grant trigger on table "public"."audit_logs" to "authenticated";

grant truncate on table "public"."audit_logs" to "authenticated";

grant delete on table "public"."audit_logs" to "service_role";

grant insert on table "public"."audit_logs" to "service_role";

grant references on table "public"."audit_logs" to "service_role";

grant select on table "public"."audit_logs" to "service_role";

grant trigger on table "public"."audit_logs" to "service_role";

grant truncate on table "public"."audit_logs" to "service_role";

grant update on table "public"."audit_logs" to "service_role";

grant delete on table "public"."audit_row_changes" to "anon";

grant insert on table "public"."audit_row_changes" to "anon";

grant references on table "public"."audit_row_changes" to "anon";

grant select on table "public"."audit_row_changes" to "anon";

grant trigger on table "public"."audit_row_changes" to "anon";

grant truncate on table "public"."audit_row_changes" to "anon";

grant update on table "public"."audit_row_changes" to "anon";

grant delete on table "public"."audit_row_changes" to "authenticated";

grant insert on table "public"."audit_row_changes" to "authenticated";

grant references on table "public"."audit_row_changes" to "authenticated";

grant select on table "public"."audit_row_changes" to "authenticated";

grant trigger on table "public"."audit_row_changes" to "authenticated";

grant truncate on table "public"."audit_row_changes" to "authenticated";

grant update on table "public"."audit_row_changes" to "authenticated";

grant delete on table "public"."audit_row_changes" to "service_role";

grant insert on table "public"."audit_row_changes" to "service_role";

grant references on table "public"."audit_row_changes" to "service_role";

grant select on table "public"."audit_row_changes" to "service_role";

grant trigger on table "public"."audit_row_changes" to "service_role";

grant truncate on table "public"."audit_row_changes" to "service_role";

grant update on table "public"."audit_row_changes" to "service_role";

grant delete on table "public"."clubs" to "anon";

grant insert on table "public"."clubs" to "anon";

grant references on table "public"."clubs" to "anon";

grant select on table "public"."clubs" to "anon";

grant trigger on table "public"."clubs" to "anon";

grant truncate on table "public"."clubs" to "anon";

grant update on table "public"."clubs" to "anon";

grant delete on table "public"."clubs" to "authenticated";

grant insert on table "public"."clubs" to "authenticated";

grant references on table "public"."clubs" to "authenticated";

grant select on table "public"."clubs" to "authenticated";

grant trigger on table "public"."clubs" to "authenticated";

grant truncate on table "public"."clubs" to "authenticated";

grant update on table "public"."clubs" to "authenticated";

grant delete on table "public"."clubs" to "service_role";

grant insert on table "public"."clubs" to "service_role";

grant references on table "public"."clubs" to "service_role";

grant select on table "public"."clubs" to "service_role";

grant trigger on table "public"."clubs" to "service_role";

grant truncate on table "public"."clubs" to "service_role";

grant update on table "public"."clubs" to "service_role";

grant delete on table "public"."consents" to "anon";

grant insert on table "public"."consents" to "anon";

grant references on table "public"."consents" to "anon";

grant select on table "public"."consents" to "anon";

grant trigger on table "public"."consents" to "anon";

grant truncate on table "public"."consents" to "anon";

grant update on table "public"."consents" to "anon";

grant delete on table "public"."consents" to "authenticated";

grant insert on table "public"."consents" to "authenticated";

grant references on table "public"."consents" to "authenticated";

grant select on table "public"."consents" to "authenticated";

grant trigger on table "public"."consents" to "authenticated";

grant truncate on table "public"."consents" to "authenticated";

grant update on table "public"."consents" to "authenticated";

grant select on table "public"."consents" to "dpo";

grant select on table "public"."consents" to "rgpd_manager";

grant delete on table "public"."consents" to "service_role";

grant insert on table "public"."consents" to "service_role";

grant references on table "public"."consents" to "service_role";

grant select on table "public"."consents" to "service_role";

grant trigger on table "public"."consents" to "service_role";

grant truncate on table "public"."consents" to "service_role";

grant update on table "public"."consents" to "service_role";

grant delete on table "public"."consumptions" to "anon";

grant insert on table "public"."consumptions" to "anon";

grant references on table "public"."consumptions" to "anon";

grant select on table "public"."consumptions" to "anon";

grant trigger on table "public"."consumptions" to "anon";

grant truncate on table "public"."consumptions" to "anon";

grant update on table "public"."consumptions" to "anon";

grant delete on table "public"."consumptions" to "authenticated";

grant insert on table "public"."consumptions" to "authenticated";

grant references on table "public"."consumptions" to "authenticated";

grant select on table "public"."consumptions" to "authenticated";

grant trigger on table "public"."consumptions" to "authenticated";

grant truncate on table "public"."consumptions" to "authenticated";

grant update on table "public"."consumptions" to "authenticated";

grant delete on table "public"."consumptions" to "service_role";

grant insert on table "public"."consumptions" to "service_role";

grant references on table "public"."consumptions" to "service_role";

grant select on table "public"."consumptions" to "service_role";

grant trigger on table "public"."consumptions" to "service_role";

grant truncate on table "public"."consumptions" to "service_role";

grant update on table "public"."consumptions" to "service_role";

grant delete on table "public"."dsar_audit" to "anon";

grant insert on table "public"."dsar_audit" to "anon";

grant references on table "public"."dsar_audit" to "anon";

grant select on table "public"."dsar_audit" to "anon";

grant trigger on table "public"."dsar_audit" to "anon";

grant truncate on table "public"."dsar_audit" to "anon";

grant update on table "public"."dsar_audit" to "anon";

grant delete on table "public"."dsar_audit" to "authenticated";

grant insert on table "public"."dsar_audit" to "authenticated";

grant references on table "public"."dsar_audit" to "authenticated";

grant select on table "public"."dsar_audit" to "authenticated";

grant trigger on table "public"."dsar_audit" to "authenticated";

grant truncate on table "public"."dsar_audit" to "authenticated";

grant update on table "public"."dsar_audit" to "authenticated";

grant delete on table "public"."dsar_audit" to "service_role";

grant insert on table "public"."dsar_audit" to "service_role";

grant references on table "public"."dsar_audit" to "service_role";

grant select on table "public"."dsar_audit" to "service_role";

grant trigger on table "public"."dsar_audit" to "service_role";

grant truncate on table "public"."dsar_audit" to "service_role";

grant update on table "public"."dsar_audit" to "service_role";

grant delete on table "public"."dsar_kms" to "anon";

grant insert on table "public"."dsar_kms" to "anon";

grant references on table "public"."dsar_kms" to "anon";

grant select on table "public"."dsar_kms" to "anon";

grant trigger on table "public"."dsar_kms" to "anon";

grant truncate on table "public"."dsar_kms" to "anon";

grant update on table "public"."dsar_kms" to "anon";

grant delete on table "public"."dsar_kms" to "authenticated";

grant insert on table "public"."dsar_kms" to "authenticated";

grant references on table "public"."dsar_kms" to "authenticated";

grant select on table "public"."dsar_kms" to "authenticated";

grant trigger on table "public"."dsar_kms" to "authenticated";

grant truncate on table "public"."dsar_kms" to "authenticated";

grant update on table "public"."dsar_kms" to "authenticated";

grant delete on table "public"."dsar_kms" to "service_role";

grant insert on table "public"."dsar_kms" to "service_role";

grant references on table "public"."dsar_kms" to "service_role";

grant select on table "public"."dsar_kms" to "service_role";

grant trigger on table "public"."dsar_kms" to "service_role";

grant truncate on table "public"."dsar_kms" to "service_role";

grant update on table "public"."dsar_kms" to "service_role";

grant delete on table "public"."dsar_requests" to "anon";

grant insert on table "public"."dsar_requests" to "anon";

grant references on table "public"."dsar_requests" to "anon";

grant select on table "public"."dsar_requests" to "anon";

grant trigger on table "public"."dsar_requests" to "anon";

grant truncate on table "public"."dsar_requests" to "anon";

grant update on table "public"."dsar_requests" to "anon";

grant delete on table "public"."dsar_requests" to "authenticated";

grant insert on table "public"."dsar_requests" to "authenticated";

grant references on table "public"."dsar_requests" to "authenticated";

grant select on table "public"."dsar_requests" to "authenticated";

grant trigger on table "public"."dsar_requests" to "authenticated";

grant truncate on table "public"."dsar_requests" to "authenticated";

grant update on table "public"."dsar_requests" to "authenticated";

grant delete on table "public"."dsar_requests" to "service_role";

grant insert on table "public"."dsar_requests" to "service_role";

grant references on table "public"."dsar_requests" to "service_role";

grant select on table "public"."dsar_requests" to "service_role";

grant trigger on table "public"."dsar_requests" to "service_role";

grant truncate on table "public"."dsar_requests" to "service_role";

grant update on table "public"."dsar_requests" to "service_role";

grant delete on table "public"."feedbacks" to "anon";

grant insert on table "public"."feedbacks" to "anon";

grant references on table "public"."feedbacks" to "anon";

grant select on table "public"."feedbacks" to "anon";

grant trigger on table "public"."feedbacks" to "anon";

grant truncate on table "public"."feedbacks" to "anon";

grant update on table "public"."feedbacks" to "anon";

grant delete on table "public"."feedbacks" to "authenticated";

grant insert on table "public"."feedbacks" to "authenticated";

grant references on table "public"."feedbacks" to "authenticated";

grant select on table "public"."feedbacks" to "authenticated";

grant trigger on table "public"."feedbacks" to "authenticated";

grant truncate on table "public"."feedbacks" to "authenticated";

grant update on table "public"."feedbacks" to "authenticated";

grant delete on table "public"."feedbacks" to "service_role";

grant insert on table "public"."feedbacks" to "service_role";

grant references on table "public"."feedbacks" to "service_role";

grant select on table "public"."feedbacks" to "service_role";

grant trigger on table "public"."feedbacks" to "service_role";

grant truncate on table "public"."feedbacks" to "service_role";

grant update on table "public"."feedbacks" to "service_role";

grant delete on table "public"."legal_holds" to "anon";

grant insert on table "public"."legal_holds" to "anon";

grant references on table "public"."legal_holds" to "anon";

grant select on table "public"."legal_holds" to "anon";

grant trigger on table "public"."legal_holds" to "anon";

grant truncate on table "public"."legal_holds" to "anon";

grant update on table "public"."legal_holds" to "anon";

grant delete on table "public"."legal_holds" to "authenticated";

grant insert on table "public"."legal_holds" to "authenticated";

grant references on table "public"."legal_holds" to "authenticated";

grant select on table "public"."legal_holds" to "authenticated";

grant trigger on table "public"."legal_holds" to "authenticated";

grant truncate on table "public"."legal_holds" to "authenticated";

grant update on table "public"."legal_holds" to "authenticated";

grant delete on table "public"."legal_holds" to "service_role";

grant insert on table "public"."legal_holds" to "service_role";

grant references on table "public"."legal_holds" to "service_role";

grant select on table "public"."legal_holds" to "service_role";

grant trigger on table "public"."legal_holds" to "service_role";

grant truncate on table "public"."legal_holds" to "service_role";

grant update on table "public"."legal_holds" to "service_role";

grant delete on table "public"."memberships" to "anon";

grant insert on table "public"."memberships" to "anon";

grant references on table "public"."memberships" to "anon";

grant select on table "public"."memberships" to "anon";

grant trigger on table "public"."memberships" to "anon";

grant truncate on table "public"."memberships" to "anon";

grant update on table "public"."memberships" to "anon";

grant delete on table "public"."memberships" to "authenticated";

grant insert on table "public"."memberships" to "authenticated";

grant references on table "public"."memberships" to "authenticated";

grant select on table "public"."memberships" to "authenticated";

grant trigger on table "public"."memberships" to "authenticated";

grant truncate on table "public"."memberships" to "authenticated";

grant update on table "public"."memberships" to "authenticated";

grant delete on table "public"."memberships" to "service_role";

grant insert on table "public"."memberships" to "service_role";

grant references on table "public"."memberships" to "service_role";

grant select on table "public"."memberships" to "service_role";

grant trigger on table "public"."memberships" to "service_role";

grant truncate on table "public"."memberships" to "service_role";

grant update on table "public"."memberships" to "service_role";

grant references on table "public"."metrics" to "anon";

grant select on table "public"."metrics" to "anon";

grant trigger on table "public"."metrics" to "anon";

grant truncate on table "public"."metrics" to "anon";

grant delete on table "public"."metrics" to "service_role";

grant insert on table "public"."metrics" to "service_role";

grant references on table "public"."metrics" to "service_role";

grant select on table "public"."metrics" to "service_role";

grant trigger on table "public"."metrics" to "service_role";

grant truncate on table "public"."metrics" to "service_role";

grant update on table "public"."metrics" to "service_role";

grant delete on table "public"."orgs" to "anon";

grant insert on table "public"."orgs" to "anon";

grant references on table "public"."orgs" to "anon";

grant select on table "public"."orgs" to "anon";

grant trigger on table "public"."orgs" to "anon";

grant truncate on table "public"."orgs" to "anon";

grant update on table "public"."orgs" to "anon";

grant delete on table "public"."orgs" to "authenticated";

grant insert on table "public"."orgs" to "authenticated";

grant references on table "public"."orgs" to "authenticated";

grant select on table "public"."orgs" to "authenticated";

grant trigger on table "public"."orgs" to "authenticated";

grant truncate on table "public"."orgs" to "authenticated";

grant update on table "public"."orgs" to "authenticated";

grant delete on table "public"."orgs" to "service_role";

grant insert on table "public"."orgs" to "service_role";

grant references on table "public"."orgs" to "service_role";

grant select on table "public"."orgs" to "service_role";

grant trigger on table "public"."orgs" to "service_role";

grant truncate on table "public"."orgs" to "service_role";

grant update on table "public"."orgs" to "service_role";

grant delete on table "public"."players" to "anon";

grant insert on table "public"."players" to "anon";

grant references on table "public"."players" to "anon";

grant select on table "public"."players" to "anon";

grant trigger on table "public"."players" to "anon";

grant truncate on table "public"."players" to "anon";

grant update on table "public"."players" to "anon";

grant delete on table "public"."players" to "authenticated";

grant insert on table "public"."players" to "authenticated";

grant references on table "public"."players" to "authenticated";

grant select on table "public"."players" to "authenticated";

grant trigger on table "public"."players" to "authenticated";

grant truncate on table "public"."players" to "authenticated";

grant update on table "public"."players" to "authenticated";

grant delete on table "public"."players" to "service_role";

grant insert on table "public"."players" to "service_role";

grant references on table "public"."players" to "service_role";

grant select on table "public"."players" to "service_role";

grant trigger on table "public"."players" to "service_role";

grant truncate on table "public"."players" to "service_role";

grant update on table "public"."players" to "service_role";

grant delete on table "public"."privacy_requests" to "anon";

grant insert on table "public"."privacy_requests" to "anon";

grant references on table "public"."privacy_requests" to "anon";

grant select on table "public"."privacy_requests" to "anon";

grant trigger on table "public"."privacy_requests" to "anon";

grant truncate on table "public"."privacy_requests" to "anon";

grant update on table "public"."privacy_requests" to "anon";

grant delete on table "public"."privacy_requests" to "authenticated";

grant insert on table "public"."privacy_requests" to "authenticated";

grant references on table "public"."privacy_requests" to "authenticated";

grant select on table "public"."privacy_requests" to "authenticated";

grant trigger on table "public"."privacy_requests" to "authenticated";

grant truncate on table "public"."privacy_requests" to "authenticated";

grant update on table "public"."privacy_requests" to "authenticated";

grant select on table "public"."privacy_requests" to "dpo";

grant select on table "public"."privacy_requests" to "rgpd_manager";

grant delete on table "public"."privacy_requests" to "service_role";

grant insert on table "public"."privacy_requests" to "service_role";

grant references on table "public"."privacy_requests" to "service_role";

grant select on table "public"."privacy_requests" to "service_role";

grant trigger on table "public"."privacy_requests" to "service_role";

grant truncate on table "public"."privacy_requests" to "service_role";

grant update on table "public"."privacy_requests" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."retention_policies" to "anon";

grant insert on table "public"."retention_policies" to "anon";

grant references on table "public"."retention_policies" to "anon";

grant select on table "public"."retention_policies" to "anon";

grant trigger on table "public"."retention_policies" to "anon";

grant truncate on table "public"."retention_policies" to "anon";

grant update on table "public"."retention_policies" to "anon";

grant delete on table "public"."retention_policies" to "authenticated";

grant insert on table "public"."retention_policies" to "authenticated";

grant references on table "public"."retention_policies" to "authenticated";

grant select on table "public"."retention_policies" to "authenticated";

grant trigger on table "public"."retention_policies" to "authenticated";

grant truncate on table "public"."retention_policies" to "authenticated";

grant update on table "public"."retention_policies" to "authenticated";

grant delete on table "public"."retention_policies" to "service_role";

grant insert on table "public"."retention_policies" to "service_role";

grant references on table "public"."retention_policies" to "service_role";

grant select on table "public"."retention_policies" to "service_role";

grant trigger on table "public"."retention_policies" to "service_role";

grant truncate on table "public"."retention_policies" to "service_role";

grant update on table "public"."retention_policies" to "service_role";

grant delete on table "public"."rgpd_runs" to "anon";

grant insert on table "public"."rgpd_runs" to "anon";

grant references on table "public"."rgpd_runs" to "anon";

grant select on table "public"."rgpd_runs" to "anon";

grant trigger on table "public"."rgpd_runs" to "anon";

grant truncate on table "public"."rgpd_runs" to "anon";

grant update on table "public"."rgpd_runs" to "anon";

grant delete on table "public"."rgpd_runs" to "authenticated";

grant insert on table "public"."rgpd_runs" to "authenticated";

grant references on table "public"."rgpd_runs" to "authenticated";

grant select on table "public"."rgpd_runs" to "authenticated";

grant trigger on table "public"."rgpd_runs" to "authenticated";

grant truncate on table "public"."rgpd_runs" to "authenticated";

grant update on table "public"."rgpd_runs" to "authenticated";

grant delete on table "public"."rgpd_runs" to "service_role";

grant insert on table "public"."rgpd_runs" to "service_role";

grant references on table "public"."rgpd_runs" to "service_role";

grant select on table "public"."rgpd_runs" to "service_role";

grant trigger on table "public"."rgpd_runs" to "service_role";

grant truncate on table "public"."rgpd_runs" to "service_role";

grant update on table "public"."rgpd_runs" to "service_role";

grant delete on table "public"."security_incidents" to "anon";

grant insert on table "public"."security_incidents" to "anon";

grant references on table "public"."security_incidents" to "anon";

grant select on table "public"."security_incidents" to "anon";

grant trigger on table "public"."security_incidents" to "anon";

grant truncate on table "public"."security_incidents" to "anon";

grant update on table "public"."security_incidents" to "anon";

grant delete on table "public"."security_incidents" to "authenticated";

grant insert on table "public"."security_incidents" to "authenticated";

grant references on table "public"."security_incidents" to "authenticated";

grant select on table "public"."security_incidents" to "authenticated";

grant trigger on table "public"."security_incidents" to "authenticated";

grant truncate on table "public"."security_incidents" to "authenticated";

grant update on table "public"."security_incidents" to "authenticated";

grant select on table "public"."security_incidents" to "dpo";

grant select on table "public"."security_incidents" to "rgpd_manager";

grant delete on table "public"."security_incidents" to "service_role";

grant insert on table "public"."security_incidents" to "service_role";

grant references on table "public"."security_incidents" to "service_role";

grant select on table "public"."security_incidents" to "service_role";

grant trigger on table "public"."security_incidents" to "service_role";

grant truncate on table "public"."security_incidents" to "service_role";

grant update on table "public"."security_incidents" to "service_role";

grant delete on table "public"."security_keys" to "anon";

grant insert on table "public"."security_keys" to "anon";

grant references on table "public"."security_keys" to "anon";

grant select on table "public"."security_keys" to "anon";

grant trigger on table "public"."security_keys" to "anon";

grant truncate on table "public"."security_keys" to "anon";

grant update on table "public"."security_keys" to "anon";

grant delete on table "public"."security_keys" to "authenticated";

grant insert on table "public"."security_keys" to "authenticated";

grant references on table "public"."security_keys" to "authenticated";

grant select on table "public"."security_keys" to "authenticated";

grant trigger on table "public"."security_keys" to "authenticated";

grant truncate on table "public"."security_keys" to "authenticated";

grant update on table "public"."security_keys" to "authenticated";

grant delete on table "public"."security_keys" to "service_role";

grant insert on table "public"."security_keys" to "service_role";

grant references on table "public"."security_keys" to "service_role";

grant select on table "public"."security_keys" to "service_role";

grant trigger on table "public"."security_keys" to "service_role";

grant truncate on table "public"."security_keys" to "service_role";

grant update on table "public"."security_keys" to "service_role";

grant delete on table "public"."staff" to "anon";

grant insert on table "public"."staff" to "anon";

grant references on table "public"."staff" to "anon";

grant select on table "public"."staff" to "anon";

grant trigger on table "public"."staff" to "anon";

grant truncate on table "public"."staff" to "anon";

grant update on table "public"."staff" to "anon";

grant delete on table "public"."staff" to "authenticated";

grant insert on table "public"."staff" to "authenticated";

grant references on table "public"."staff" to "authenticated";

grant select on table "public"."staff" to "authenticated";

grant trigger on table "public"."staff" to "authenticated";

grant truncate on table "public"."staff" to "authenticated";

grant update on table "public"."staff" to "authenticated";

grant delete on table "public"."staff" to "service_role";

grant insert on table "public"."staff" to "service_role";

grant references on table "public"."staff" to "service_role";

grant select on table "public"."staff" to "service_role";

grant trigger on table "public"."staff" to "service_role";

grant truncate on table "public"."staff" to "service_role";

grant update on table "public"."staff" to "service_role";

grant delete on table "public"."sticks" to "anon";

grant insert on table "public"."sticks" to "anon";

grant references on table "public"."sticks" to "anon";

grant select on table "public"."sticks" to "anon";

grant trigger on table "public"."sticks" to "anon";

grant truncate on table "public"."sticks" to "anon";

grant update on table "public"."sticks" to "anon";

grant delete on table "public"."sticks" to "authenticated";

grant insert on table "public"."sticks" to "authenticated";

grant references on table "public"."sticks" to "authenticated";

grant select on table "public"."sticks" to "authenticated";

grant trigger on table "public"."sticks" to "authenticated";

grant truncate on table "public"."sticks" to "authenticated";

grant update on table "public"."sticks" to "authenticated";

grant delete on table "public"."sticks" to "service_role";

grant insert on table "public"."sticks" to "service_role";

grant references on table "public"."sticks" to "service_role";

grant select on table "public"."sticks" to "service_role";

grant trigger on table "public"."sticks" to "service_role";

grant truncate on table "public"."sticks" to "service_role";

grant update on table "public"."sticks" to "service_role";

create policy "audit_select"
on "public"."audit_logs"
as permissive
for select
to authenticated
using ((((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id)) OR (actor_user_id = auth.uid())));


create policy "clubs: delete by org admin"
on "public"."clubs"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = clubs.org_id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))));


create policy "clubs: insert by org admin"
on "public"."clubs"
as permissive
for insert
to authenticated
with check ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = clubs.org_id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))));


create policy "clubs: read all (dev)"
on "public"."clubs"
as permissive
for select
to authenticated
using (true);


create policy "clubs: read of my orgs"
on "public"."clubs"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = clubs.org_id) AND (m.user_id = auth.uid())))));


create policy "clubs: update by org admin"
on "public"."clubs"
as permissive
for update
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = clubs.org_id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))))
with check ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = clubs.org_id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))));


create policy "select_default"
on "public"."clubs"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(clubs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(clubs.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."clubs"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(clubs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(clubs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "consents_delete"
on "public"."consents"
as permissive
for delete
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "consents_insert"
on "public"."consents"
as permissive
for insert
to authenticated
with check (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "consents_select"
on "public"."consents"
as permissive
for select
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "consents_update"
on "public"."consents"
as permissive
for update
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))))
with check (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "select_default"
on "public"."consents"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consents.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(consents.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."consents"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consents.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consents.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "Players insert their own consumption"
on "public"."consumptions"
as permissive
for insert
to public
with check ((player_id = auth.uid()));


create policy "Staff can read consumptions of their club"
on "public"."consumptions"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM (players p
     JOIN staff s ON ((s.club_id = p.club_id)))
  WHERE ((s.id = auth.uid()) AND (p.id = consumptions.player_id)))));


create policy "select_default"
on "public"."consumptions"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consumptions.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(consumptions.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."consumptions"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consumptions.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(consumptions.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "no_read"
on "public"."dsar_kms"
as permissive
for all
to public
using (false)
with check (false);


create policy "dsar_delete"
on "public"."dsar_requests"
as permissive
for delete
to authenticated
using (((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id)));


create policy "dsar_insert"
on "public"."dsar_requests"
as permissive
for insert
to authenticated
with check (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "dsar_select"
on "public"."dsar_requests"
as permissive
for select
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "dsar_update"
on "public"."dsar_requests"
as permissive
for update
to authenticated
using (((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id)))
with check (((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id)));


create policy "select_default"
on "public"."dsar_requests"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(dsar_requests.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(dsar_requests.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."dsar_requests"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(dsar_requests.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(dsar_requests.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "feedbacks_delete"
on "public"."feedbacks"
as permissive
for delete
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "feedbacks_insert"
on "public"."feedbacks"
as permissive
for insert
to authenticated
with check (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "feedbacks_select"
on "public"."feedbacks"
as permissive
for select
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "feedbacks_update"
on "public"."feedbacks"
as permissive
for update
to authenticated
using (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))))
with check (((user_id = auth.uid()) OR ((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id))));


create policy "select_default"
on "public"."feedbacks"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(feedbacks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(feedbacks.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."feedbacks"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(feedbacks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(feedbacks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "mship: read own or org admin"
on "public"."memberships"
as permissive
for select
to authenticated
using (((user_id = auth.uid()) OR is_org_admin(org_id)));


create policy "mship: select self rows"
on "public"."memberships"
as permissive
for select
to authenticated
using ((user_id = auth.uid()));


create policy "select_default"
on "public"."memberships"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(memberships.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(memberships.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."memberships"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(memberships.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(memberships.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "Metrics visible only to same org"
on "public"."metrics"
as permissive
for select
to public
using ((auth.uid() = org_id));


create policy "metrics_select"
on "public"."metrics"
as permissive
for select
to authenticated
using (((org_id IS NOT NULL) AND is_org_staff_or_admin(org_id)));


create policy "select_default"
on "public"."metrics"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(metrics.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(metrics.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."metrics"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(metrics.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(metrics.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "orgs: delete only admin"
on "public"."orgs"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = orgs.id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))));


create policy "orgs: insert only as self creator"
on "public"."orgs"
as permissive
for insert
to authenticated
with check ((created_by = auth.uid()));


create policy "orgs: read if creator or member"
on "public"."orgs"
as permissive
for select
to authenticated
using (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = orgs.id) AND (m.user_id = auth.uid()))))));


create policy "orgs: update only admin"
on "public"."orgs"
as permissive
for update
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = orgs.id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))))
with check ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = orgs.id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role)))));


create policy "select_default"
on "public"."orgs"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(orgs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(orgs.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."orgs"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(orgs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(orgs.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "players: delete by admin"
on "public"."players"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = players.org_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role]))))));


create policy "players: delete by owner or admin"
on "public"."players"
as permissive
for delete
to public
using (((owner_id = auth.uid()) OR is_org_admin(org_id)));


create policy "players: insert by owner & org member"
on "public"."players"
as permissive
for insert
to public
with check (((owner_id = auth.uid()) AND (is_org_member(org_id) OR is_org_staff_or_admin(org_id))));


create policy "players: insert self"
on "public"."players"
as permissive
for insert
to authenticated
with check ((owner_id = auth.uid()));


create policy "players: select by owner or staff"
on "public"."players"
as permissive
for select
to public
using (((owner_id = auth.uid()) OR is_org_staff_or_admin(org_id)));


create policy "players: select owner or org staff"
on "public"."players"
as permissive
for select
to authenticated
using (((owner_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = players.org_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))));


create policy "players: update by org staff"
on "public"."players"
as permissive
for update
to public
using (is_org_staff_or_admin(org_id))
with check (is_org_staff_or_admin(org_id));


create policy "players: update by owner"
on "public"."players"
as permissive
for update
to public
using ((owner_id = auth.uid()))
with check ((owner_id = auth.uid()));


create policy "players: update owner or org staff"
on "public"."players"
as permissive
for update
to authenticated
using (((owner_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = players.org_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))))
with check (((owner_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.org_id = players.org_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))));


create policy "select_default"
on "public"."players"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(players.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(players.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."players"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(players.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(players.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "profiles: insert self"
on "public"."profiles"
as permissive
for insert
to authenticated
with check ((id = auth.uid()));


create policy "profiles: read self"
on "public"."profiles"
as permissive
for select
to authenticated
using ((id = auth.uid()));


create policy "profiles: select own"
on "public"."profiles"
as permissive
for select
to authenticated
using ((id = auth.uid()));


create policy "profiles: select self"
on "public"."profiles"
as permissive
for select
to authenticated
using ((id = auth.uid()));


create policy "profiles: update own"
on "public"."profiles"
as permissive
for update
to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));


create policy "profiles: update self"
on "public"."profiles"
as permissive
for update
to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));


create policy "profiles: upsert self"
on "public"."profiles"
as permissive
for insert
to authenticated
with check ((id = auth.uid()));


create policy "select_default"
on "public"."profiles"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(profiles.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(profiles.*) ->> 'org_id'::text), ''::text)))))));


create policy "write_default"
on "public"."profiles"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(profiles.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(profiles.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "select_default"
on "public"."staff"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(staff.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(staff.*) ->> 'org_id'::text), ''::text)))))));


create policy "staff_org_read"
on "public"."staff"
as permissive
for select
to authenticated
using (is_org_member(club_id));


create policy "staff_org_write"
on "public"."staff"
as permissive
for all
to authenticated
using ((is_org_member(club_id) AND is_org_role(club_id, ARRAY['coach'::org_role, 'admin'::org_role])))
with check ((is_org_member(club_id) AND is_org_role(club_id, ARRAY['coach'::org_role, 'admin'::org_role])));


create policy "write_default"
on "public"."staff"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(staff.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(staff.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


create policy "select_default"
on "public"."sticks"
as permissive
for select
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(sticks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text) OR (EXISTS ( SELECT 1
   FROM memberships m2
  WHERE ((m2.user_id = auth.uid()) AND ((m2.org_id)::text = COALESCE((to_jsonb(sticks.*) ->> 'org_id'::text), ''::text)))))));


create policy "sticks: delete owner pending or admin"
on "public"."sticks"
as permissive
for delete
to authenticated
using ((((requested_by = auth.uid()) AND (status = 'pending'::stick_status)) OR (EXISTS ( SELECT 1
   FROM (clubs c
     JOIN memberships m ON ((m.org_id = c.org_id)))
  WHERE ((c.id = sticks.club_id) AND (m.user_id = auth.uid()) AND (m.role = 'admin'::org_role))))));


create policy "sticks: insert self"
on "public"."sticks"
as permissive
for insert
to authenticated
with check ((requested_by = auth.uid()));


create policy "sticks: select owner or org staff"
on "public"."sticks"
as permissive
for select
to authenticated
using (((requested_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (clubs c
     JOIN memberships m ON ((m.org_id = c.org_id)))
  WHERE ((c.id = sticks.club_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))));


create policy "sticks: update owner pending or org staff"
on "public"."sticks"
as permissive
for update
to authenticated
using ((((requested_by = auth.uid()) AND (status = 'pending'::stick_status)) OR (EXISTS ( SELECT 1
   FROM (clubs c
     JOIN memberships m ON ((m.org_id = c.org_id)))
  WHERE ((c.id = sticks.club_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))))
with check ((((requested_by = auth.uid()) AND (status = 'pending'::stick_status)) OR (EXISTS ( SELECT 1
   FROM (clubs c
     JOIN memberships m ON ((m.org_id = c.org_id)))
  WHERE ((c.id = sticks.club_id) AND (m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'coach'::org_role])))))));


create policy "write_default"
on "public"."sticks"
as permissive
for all
to authenticated
using (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(sticks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)))
with check (((EXISTS ( SELECT 1
   FROM memberships m
  WHERE ((m.user_id = auth.uid()) AND (m.role = ANY (ARRAY['admin'::org_role, 'staff'::org_role]))))) OR (COALESCE((to_jsonb(sticks.*) ->> 'user_id'::text), ''::text) = (auth.uid())::text)));


CREATE TRIGGER dsar_audit_mac BEFORE INSERT OR UPDATE ON public.dsar_audit FOR EACH ROW EXECUTE FUNCTION trg_dsar_audit_mac();

CREATE CONSTRAINT TRIGGER dsar_kms_exactly_one_active AFTER INSERT OR DELETE OR UPDATE ON public.dsar_kms DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION trg_dsar_kms_exactly_one_active();

CREATE TRIGGER trg_membership_admin_delete BEFORE DELETE ON public.memberships FOR EACH ROW EXECUTE FUNCTION ensure_org_has_admin();

CREATE TRIGGER trg_membership_admin_update BEFORE UPDATE ON public.memberships FOR EACH ROW EXECUTE FUNCTION ensure_org_has_admin();

CREATE TRIGGER trg_audit_change_metrics AFTER INSERT OR DELETE OR UPDATE ON public.metrics FOR EACH ROW EXECUTE FUNCTION fn_audit_row_change();

CREATE TRIGGER trg_audit_change_orgs AFTER INSERT OR DELETE OR UPDATE ON public.orgs FOR EACH ROW EXECUTE FUNCTION fn_audit_row_change();

CREATE TRIGGER trg_audit_change_players AFTER INSERT OR DELETE OR UPDATE ON public.players FOR EACH ROW EXECUTE FUNCTION fn_audit_row_change();

CREATE TRIGGER trg_audit_change_profiles AFTER INSERT OR DELETE OR UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION fn_audit_row_change();

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_audit_change_staff AFTER INSERT OR DELETE OR UPDATE ON public.staff FOR EACH ROW EXECUTE FUNCTION fn_audit_row_change();

CREATE TRIGGER sticks_set_club_id_trg BEFORE INSERT OR UPDATE ON public.sticks FOR EACH ROW EXECUTE FUNCTION sticks_set_club_id();

CREATE TRIGGER trg_sticks_set_club_id BEFORE INSERT ON public.sticks FOR EACH ROW EXECUTE FUNCTION sticks_set_club_id();


CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();


