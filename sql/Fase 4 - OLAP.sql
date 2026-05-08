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