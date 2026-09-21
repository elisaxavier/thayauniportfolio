-- ============================================================
-- BANCO DE DADOS - ADMIN THAYNA AUNI
-- ============================================================
-- Cole todo este arquivo no Supabase, na aba "SQL Editor"
-- Se aparecer erro de tabela que já existe, é seguro ignorar
-- ============================================================

-- TABELA 1: VÍDEOS
-- Guarda todos os vídeos do seu portfólio
CREATE TABLE IF NOT EXISTS videos (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  titulo TEXT NOT NULL,
  link TEXT NOT NULL,
  nicho TEXT,
  formato TEXT,
  marca TEXT,
  destaque TEXT,
  ordem INT DEFAULT 999,
  visivel BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TABELA 2: MARCAS
-- Sua base de contatos de empresas
CREATE TABLE IF NOT EXISTS marcas (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  nome TEXT NOT NULL,
  instagram TEXT,
  email TEXT,
  telefone TEXT,
  situacao TEXT DEFAULT 'Lead',
  obs TEXT,
  ultimo_contato TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TABELA 3: CALENDÁRIO
-- Suas tarefas mensais
CREATE TABLE IF NOT EXISTS calendario (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  titulo TEXT NOT NULL,
  marca TEXT,
  tipo TEXT,
  data DATE NOT NULL,
  status TEXT DEFAULT 'a fazer',
  created_at TIMESTAMP DEFAULT NOW()
);

-- TABELA 4: CAMPANHAS
-- Suas campanhas com clientes, status e valores
CREATE TABLE IF NOT EXISTS campanhas (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  campanha TEXT NOT NULL,
  cliente TEXT NOT NULL,
  tipo TEXT,
  status TEXT DEFAULT 'Briefing',
  qtd INT DEFAULT 1,
  valor DECIMAL(10,2),
  prazo DATE,
  pagamento TEXT DEFAULT 'pendente',
  ativa BOOLEAN DEFAULT true,
  favorita BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TABELA 5: MARCADOS (CHECKLIST)
-- Salva quais itens do checklist você já marcou
CREATE TABLE IF NOT EXISTS marcados (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  chave TEXT NOT NULL UNIQUE,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- TABELA 6: VISITAS
-- Registra cada visita no seu portfólio
CREATE TABLE IF NOT EXISTS visitas (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  data TIMESTAMP DEFAULT NOW(),
  pagina TEXT,
  origem TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) - A TRANCA DO SEU BANCO
-- ============================================================
-- A partir daqui, só você logado pode ler e escrever
-- Exceção 1: Qualquer um insere marcas (vem do formulário)
-- Exceção 2: Qualquer um insere visitas (métrica do site)

-- ATIVAR RLS EM TODAS AS TABELAS
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendario ENABLE ROW LEVEL SECURITY;
ALTER TABLE campanhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE marcados ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitas ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- POLÍTICAS PARA: videos
-- Só você lê e escreve
ALTER TABLE videos FORCE ROW LEVEL SECURITY;
CREATE POLICY "Você lê seus vídeos" ON videos
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você cria vídeos" ON videos
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Você edita vídeos" ON videos
  FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você deleta vídeos" ON videos
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- POLÍTICAS PARA: marcas
-- Qualquer um insere (formulário do site)
-- Só você lê (sua base é privada)
-- Só você edita
ALTER TABLE marcas FORCE ROW LEVEL SECURITY;
CREATE POLICY "Qualquer um insere marca" ON marcas
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Você lê suas marcas" ON marcas
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você edita marcas" ON marcas
  FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você deleta marcas" ON marcas
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- POLÍTICAS PARA: calendario
-- Só você lê e escreve
ALTER TABLE calendario FORCE ROW LEVEL SECURITY;
CREATE POLICY "Você lê seu calendário" ON calendario
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você cria eventos" ON calendario
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Você edita eventos" ON calendario
  FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você deleta eventos" ON calendario
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- POLÍTICAS PARA: campanhas
-- Só você lê e escreve
ALTER TABLE campanhas FORCE ROW LEVEL SECURITY;
CREATE POLICY "Você lê suas campanhas" ON campanhas
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você cria campanhas" ON campanhas
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Você edita campanhas" ON campanhas
  FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você deleta campanhas" ON campanhas
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- POLÍTICAS PARA: marcados (CHECKLIST)
-- Só você lê e escreve
ALTER TABLE marcados FORCE ROW LEVEL SECURITY;
CREATE POLICY "Você lê seus marcados" ON marcados
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você marca itens" ON marcados
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Você desmarca itens" ON marcados
  FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Você deleta marcados" ON marcados
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- POLÍTICAS PARA: visitas
-- Qualquer um insere (métrica do site, sem serviço externo)
-- Só você lê (seus dados de visitante)
-- Ninguém edita ou deleta
ALTER TABLE visitas FORCE ROW LEVEL SECURITY;
CREATE POLICY "Qualquer um registra visita" ON visitas
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Você lê suas visitas" ON visitas
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================================
-- DADOS DE EXEMPLO (apague depois)
-- ============================================================
INSERT INTO videos (titulo, link, nicho, formato, marca, destaque, ordem, visivel)
VALUES ('Exemplo de vídeo', 'https://youtube.com/shorts/xxxxx', 'food', 'UGC', 'Marca Exemplo', '+2.4M views', 1, true);

INSERT INTO marcas (nome, instagram, email, telefone, situacao, obs, ultimo_contato)
VALUES ('Marca Exemplo', '@marca.exemplo', 'contato@marca.com', '11999999999', 'Lead', 'Veio do formulário', NOW());

INSERT INTO calendario (titulo, marca, tipo, data, status)
VALUES ('Exemplo de tarefa', 'Marca Exemplo', 'gravar', CURRENT_DATE, 'a fazer');

INSERT INTO campanhas (campanha, cliente, tipo, status, qtd, valor, prazo, pagamento, ativa, favorita)
VALUES ('Exemplo de campanha', 'Marca Exemplo', 'Conteúdo', 'Briefing', 3, 1500.00, CURRENT_DATE + INTERVAL '7 days', 'pendente', true, false);

INSERT INTO visitas (pagina, origem)
VALUES ('/', 'direto');
