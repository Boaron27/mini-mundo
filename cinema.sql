CREATE SEQUENCE seq_endereco START 1;
CREATE SEQUENCE seq_cinema START 1;
CREATE SEQUENCE seq_telefone START 1;
CREATE SEQUENCE seq_cliente START 1;
CREATE SEQUENCE seq_funcionario START 1;
CREATE SEQUENCE seq_sala START 1;
CREATE SEQUENCE seq_genero START 1;
CREATE SEQUENCE seq_filme START 1;
CREATE SEQUENCE seq_participante START 1;
CREATE SEQUENCE seq_equipe_filme START 1;
CREATE SEQUENCE seq_exibe_sessao START 1;
CREATE SEQUENCE seq_ingresso START 1;


CREATE TABLE endereco (
    id_endereco INT NOT NULL PRIMARY KEY,
    logradouro VARCHAR(50) NOT NULL,
    numero VARCHAR(9) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    municipio VARCHAR(50) NOT NULL,
    estado VARCHAR(2) -- Não colocamos not null para utilizar other join
);

CREATE TABLE cinema (
    id_cinema INT NOT NULL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    id_endereco INT NOT NULL,
    FOREIGN KEY (id_endereco) REFERENCES endereco (id_endereco) ON DELETE CASCADE
);

CREATE TABLE pessoa (
    cpf VARCHAR(20) NOT NULL,
    nome VARCHAR(50) NOT NULL CHECK (LENGTH(nome) > 1),
    sobrenome VARCHAR(50) NULL CHECK (LENGTH(sobrenome) > 1),
    email VARCHAR(50) NOT NULL CHECK (LENGTH(email) > 5),
    PRIMARY KEY (cpf)
);

CREATE TABLE telefone (
    id_telefone INT NOT NULL PRIMARY KEY,
    cpf VARCHAR(20) NOT NULL CHECK (LENGTH(cpf) > 10),
    telefone VARCHAR(20) NOT NULL,
    FOREIGN KEY (cpf) REFERENCES pessoa (cpf) ON DELETE CASCADE
);

CREATE UNIQUE INDEX index_telefone ON telefone (cpf, telefone);

CREATE TABLE cliente (
    id_cliente INT NOT NULL PRIMARY KEY,
    cpf VARCHAR(20) NOT NULL CHECK (LENGTH(cpf) > 10),
    idade INT NULL CHECK (idade > 0),
    tipo VARCHAR(30) NOT NULL,
    FOREIGN KEY (cpf) REFERENCES pessoa (cpf) ON DELETE CASCADE
);

CREATE TABLE funcionario (
    id_funcionario INT NOT NULL PRIMARY KEY,
    cpf VARCHAR(20) NOT NULL CHECK (LENGTH(cpf) > 10),
    id_cinema INT NOT NULL,
    FOREIGN KEY (id_cinema) REFERENCES cinema (id_cinema) ON DELETE CASCADE,
    FOREIGN KEY (cpf) REFERENCES pessoa (cpf) ON DELETE CASCADE
);

CREATE TABLE sala (
    id_sala INT NOT NULL PRIMARY KEY,
    id_cinema INT NOT NULL,
    lotacao INT NOT NULL CHECK (lotacao > 0),
    FOREIGN KEY (id_cinema) REFERENCES cinema (id_cinema) ON DELETE CASCADE
);

CREATE TABLE genero (
    id_genero INT NOT NULL PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE filme (
    id_filme INT NOT NULL PRIMARY KEY,
    id_genero INT NOT NULL,
    data_lancamento DATE NOT NULL,
    duracao INT CHECK (duracao >= 0),
    sinopse VARCHAR(60) NOT NULL,
    titulo VARCHAR(50) NOT NULL,
    produtora VARCHAR(50),
    FOREIGN KEY (id_genero) REFERENCES genero (id_genero) ON DELETE CASCADE
);

CREATE TABLE participante (
    id_participante INT NOT NULL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL CHECK (LENGTH(nome) > 1),
    sobrenome VARCHAR(50) CHECK (LENGTH(sobrenome) > 1),
    tipo VARCHAR(50)
);

CREATE TABLE estrangeiro (
    titulo_portugues VARCHAR(50) NOT NULL CHECK (LENGTH(titulo_portugues) > 1),
    id_filme INT NOT NULL,
    pais_origem VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_filme) REFERENCES filme (id_filme) ON DELETE CASCADE
);

CREATE TABLE equipe_filme (
    id_equipe_filme INT NOT NULL PRIMARY KEY,
    id_participante INT NOT NULL,
    id_filme INT NOT NULL,
    FOREIGN KEY (id_participante) REFERENCES participante (id_participante) ON DELETE CASCADE,
    FOREIGN KEY (id_filme) REFERENCES filme (id_filme) ON DELETE CASCADE
);

CREATE TABLE exibe_sessao (
    id_sessao INT NOT NULL PRIMARY KEY,
    id_sala INT NOT NULL,
    id_filme INT NOT NULL,
    hora_inicio VARCHAR(10) NOT NULL,
    hora_final VARCHAR(10) NOT NULL,
    data_sessao DATE NOT NULL,
    FOREIGN KEY (id_sala) REFERENCES sala (id_sala) ON DELETE CASCADE,
    FOREIGN KEY (id_filme) REFERENCES filme (id_filme) ON DELETE CASCADE
);

CREATE TABLE ingresso (
    id_ingresso INT NOT NULL PRIMARY KEY,
    valor DECIMAL(9,2) NOT NULL,
    id_sessao INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_sessao) REFERENCES exibe_sessao (id_sessao) ON DELETE CASCADE,
    FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION validar_cpf() RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.cpf) != 11 THEN
        RAISE EXCEPTION 'CPF deve ter exatamente 11 dígitos';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cpf
BEFORE INSERT OR UPDATE ON pessoa
FOR EACH ROW
EXECUTE FUNCTION validar_cpf();

