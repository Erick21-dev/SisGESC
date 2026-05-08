INSERT IGNORE INTO tb_alunos (nome, cpf, status_aluno, saldo) VALUES ('João Silva', '12345678901', 'Ativo', 1000);

INSERT IGNORE INTO tb_cursos (nome, duracao_semestres) VALUES ('ADS', 6);

INSERT IGNORE INTO tb_matriculas (fk_aluno, fk_curso) VALUES (1, 1);

INSERT IGNORE INTO tb_mensalidades (fk_aluno, valor, mes_referencia) VALUES (1, 500.00, '2026-05');

INSERT IGNORE INTO tb_pagamentos (fk_mensalidade, valor_pago, data_pagamento) VALUES (1, 500.00, CURDATE());

INSERT IGNORE INTO tb_funcionarios (nome, cpf, cargo, salario) VALUES ('Carlos Mendes', '98765432100', 'Professor', 4500);

SELECT 'PRIMEIRA EXECUÇÃO' AS status_carga, COUNT(*) AS total_alunos FROM tb_alunos;

INSERT IGNORE INTO tb_alunos (nome, cpf, status_aluno, saldo) VALUES ('João Silva', '12345678901', 'Ativo', 1000);

SELECT 'SEGUNDA EXECUÇÃO' AS status_carga, COUNT(*) AS total_alunos FROM tb_alunos;