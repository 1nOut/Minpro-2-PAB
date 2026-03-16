-- ============================================================
-- SUPABASE SETUP — Top Up Game Mini Project 2
-- Jalankan di: Supabase Dashboard > SQL Editor > New Query
-- ============================================================


-- ============================================================
-- 1. TABEL GAMES
-- ============================================================
CREATE TABLE IF NOT EXISTS games (
  id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama  text NOT NULL,
  logo  text NOT NULL DEFAULT 'assets/image/ml.png',
  stok  int  NOT NULL DEFAULT 0 CHECK (stok >= 0)
);

ALTER TABLE games ENABLE ROW LEVEL SECURITY;

CREATE POLICY "games_select" ON games
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "games_insert" ON games
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "games_update" ON games
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "games_delete" ON games
  FOR DELETE USING (auth.role() = 'authenticated');


-- ============================================================
-- 2. TABEL TRANSAKSI
-- ============================================================
CREATE TABLE IF NOT EXISTS transaksi (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        REFERENCES auth.users(id) ON DELETE CASCADE,
  nama_game  text        NOT NULL,
  id_player  text        NOT NULL,
  jumlah     int         NOT NULL CHECK (jumlah > 0),
  email      text        NOT NULL,
  status     text        NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'selesai')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE transaksi ENABLE ROW LEVEL SECURITY;

CREATE POLICY "transaksi_select" ON transaksi
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "transaksi_insert" ON transaksi
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "transaksi_update" ON transaksi
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "transaksi_delete" ON transaksi
  FOR DELETE USING (auth.uid() = user_id);


-- ============================================================
-- 3. DATA AWAL (SEED) — 3 Game Default
-- ============================================================
INSERT INTO games (nama, logo, stok) VALUES
  ('Mobile Legends', 'assets/image/ml.png',   5000),
  ('Free Fire',      'assets/image/ff.png',   3000),
  ('PUBG Mobile',    'assets/image/pubgm.png', 2000);
