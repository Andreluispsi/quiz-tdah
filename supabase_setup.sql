-- =============================================
-- Quiz TDAH - Supabase Table Setup
-- Run this in Supabase SQL Editor
-- =============================================

-- 1. Create quiz_leads table
CREATE TABLE IF NOT EXISTS quiz_leads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  whatsapp TEXT,
  profile TEXT NOT NULL,
  dimensions JSONB NOT NULL DEFAULT '{}',
  answers JSONB NOT NULL DEFAULT '[]',
  recommended_products TEXT[] DEFAULT '{}',
  source TEXT DEFAULT 'organic',
  utm_source TEXT,
  utm_medium TEXT,
  utm_campaign TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_quiz_leads_email ON quiz_leads(email);
CREATE INDEX IF NOT EXISTS idx_quiz_leads_profile ON quiz_leads(profile);
CREATE INDEX IF NOT EXISTS idx_quiz_leads_created ON quiz_leads(created_at DESC);

-- 3. RLS: Enable Row Level Security
ALTER TABLE quiz_leads ENABLE ROW LEVEL SECURITY;

-- 4. Policy: Allow anonymous inserts (quiz submissions from frontend)
CREATE POLICY "Allow anonymous quiz submissions"
  ON quiz_leads
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- 5. Policy: Only authenticated/service role can read
CREATE POLICY "Only service role can read quiz leads"
  ON quiz_leads
  FOR SELECT
  TO authenticated
  USING (true);

-- 6. Policy: Service role full access (for admin/CRM)
CREATE POLICY "Service role full access"
  ON quiz_leads
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- 7. Useful view for analytics
CREATE OR REPLACE VIEW quiz_analytics AS
SELECT
  profile,
  COUNT(*) as total,
  COUNT(DISTINCT email) as unique_leads,
  COUNT(whatsapp) FILTER (WHERE whatsapp IS NOT NULL) as with_whatsapp,
  DATE(created_at) as date
FROM quiz_leads
GROUP BY profile, DATE(created_at)
ORDER BY date DESC, total DESC;
