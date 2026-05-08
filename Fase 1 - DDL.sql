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