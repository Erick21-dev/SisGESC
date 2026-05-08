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