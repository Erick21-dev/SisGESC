DROP DATABASE IF EXISTS sisgesc;
CREATE DATABASE sisgesc;
USE sisgesc;

CREATE TABLE tb_alunos (
    pk_rgm_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE, 
    status_aluno VARCHAR(20) NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT chk_status_aluno CHECK (status_aluno IN ('Ativo', 'Inativo', 'Trancado', 'Formado', 'Transferido'))
);

CREATE TABLE tb_cursos (
    pk_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    duracao_semestres INT NOT NULL
);

CREATE TABLE tb_matriculas (
    pk_matricula INT AUTO_INCREMENT PRIMARY KEY,
    fk_aluno INT NOT NULL,
    fk_curso INT NOT NULL,
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (fk_aluno) REFERENCES tb_alunos(pk_rgm_aluno),
    CONSTRAINT fk_matricula_curso FOREIGN KEY (fk_curso) REFERENCES tb_cursos(pk_curso),
    CONSTRAINT unq_matricula UNIQUE (fk_aluno, fk_curso)
);

CREATE TABLE tb_mensalidades (
    pk_mensalidade INT AUTO_INCREMENT PRIMARY KEY,
    fk_aluno INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    mes_referencia VARCHAR(10) NOT NULL,
    CONSTRAINT fk_mensalidade_aluno FOREIGN KEY (fk_aluno) REFERENCES tb_alunos(pk_rgm_aluno),
    CONSTRAINT unq_mensalidade UNIQUE (fk_aluno, mes_referencia)
);

CREATE TABLE tb_pagamentos (
    pk_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    fk_mensalidade INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento DATE NOT NULL,
    CONSTRAINT fk_pagamento_mensalidade FOREIGN KEY (fk_mensalidade) REFERENCES tb_mensalidades(pk_mensalidade),
    CONSTRAINT unq_pagamento UNIQUE (fk_mensalidade, data_pagamento)
);

CREATE TABLE tb_funcionarios (
    pk_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10,2) NOT NULL
);
INSERT IGNORE INTO tb_alunos (nome, cpf, status_aluno, saldo) VALUES ('João Silva', '12345678901', 'Ativo', 1000);

INSERT IGNORE INTO tb_cursos (nome, duracao_semestres) VALUES ('ADS', 6);

INSERT IGNORE INTO tb_matriculas (fk_aluno, fk_curso) VALUES (1, 1);

INSERT IGNORE INTO tb_mensalidades (fk_aluno, valor, mes_referencia) VALUES (1, 500.00, '2026-05');

INSERT IGNORE INTO tb_pagamentos (fk_mensalidade, valor_pago, data_pagamento) VALUES (1, 500.00, CURDATE());

INSERT IGNORE INTO tb_funcionarios (nome, cpf, cargo, salario) VALUES ('Carlos Mendes', '98765432100', 'Professor', 4500);

SELECT 'PRIMEIRA EXECUÇÃO' AS status_carga, COUNT(*) AS total_alunos FROM tb_alunos;

INSERT IGNORE INTO tb_alunos (nome, cpf, status_aluno, saldo) VALUES ('João Silva', '12345678901', 'Ativo', 1000);

SELECT 'SEGUNDA EXECUÇÃO' AS status_carga, COUNT(*) AS total_alunos FROM tb_alunos;

SELECT nome FROM tb_alunos 
WHERE pk_rgm_aluno IN (
    SELECT m.fk_aluno FROM tb_mensalidades m
    JOIN tb_pagamentos p ON m.pk_mensalidade = p.fk_mensalidade
    GROUP BY m.fk_aluno
    HAVING SUM(p.valor_pago) > 400
);

START TRANSACTION;

UPDATE tb_alunos SET saldo = saldo - 500 WHERE pk_rgm_aluno = 1;

ROLLBACK;

START TRANSACTION;

INSERT IGNORE INTO tb_mensalidades (fk_aluno, valor, mes_referencia) VALUES (1, 600.00, '2026-06');

COMMIT;

CREATE TABLE dim_tempo (
    sk_tempo INT AUTO_INCREMENT PRIMARY KEY,
    data_completa DATE UNIQUE,
    nome_mes VARCHAR(20),
    ano INT
);

CREATE TABLE dim_aluno (
    sk_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nk_aluno INT UNIQUE,
    nome VARCHAR(100)
);

CREATE TABLE fato_financeiro (
    id_fato INT AUTO_INCREMENT PRIMARY KEY,
    sk_tempo INT,
    sk_aluno INT,
    valor_total DECIMAL(10,2),
    CONSTRAINT fk_fato_tempo FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_aluno FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno)
);

INSERT IGNORE INTO dim_tempo (data_completa, nome_mes, ano) 
VALUES (CURDATE(), MONTHNAME(CURDATE()), YEAR(CURDATE()));

INSERT IGNORE INTO dim_aluno (nk_aluno, nome) 
SELECT pk_rgm_aluno, nome FROM tb_alunos;

TRUNCATE TABLE fato_financeiro;

INSERT INTO fato_financeiro (sk_tempo, sk_aluno, valor_total)
SELECT dt.sk_tempo, da.sk_aluno, SUM(p.valor_pago)
FROM tb_pagamentos p
JOIN tb_mensalidades m ON p.fk_mensalidade = m.pk_mensalidade
JOIN dim_aluno da ON m.fk_aluno = da.nk_aluno
JOIN dim_tempo dt ON p.data_pagamento = dt.data_completa
GROUP BY dt.sk_tempo, da.sk_aluno;

SELECT 
    (SELECT SUM(valor_pago) FROM tb_pagamentos) AS total_oltp,
    (SELECT SUM(valor_total) FROM fato_financeiro) AS total_olap;
    
    EXPLAIN SELECT p.valor_pago FROM tb_pagamentos p 
JOIN tb_mensalidades m ON p.fk_mensalidade = m.pk_mensalidade 
WHERE p.data_pagamento = CURDATE();

CREATE INDEX idx_pagamento_data ON tb_pagamentos(data_pagamento);

CREATE INDEX idx_mensalidade_aluno ON tb_mensalidades(fk_aluno);

EXPLAIN SELECT p.valor_pago FROM tb_pagamentos p 
JOIN tb_mensalidades m ON p.fk_mensalidade = m.pk_mensalidade 
WHERE p.data_pagamento = CURDATE();