CREATE SEQUENCE seq_hotel START 1;
CREATE SEQUENCE seq_cep START 1;
CREATE SEQUENCE seq_pessoa START 1;
CREATE SEQUENCE seq_cliente START 1;
CREATE SEQUENCE seq_cargo START 1;
CREATE SEQUENCE seq_funcionario START 1;
CREATE SEQUENCE seq_transporte START 1;
CREATE SEQUENCE seq_forma_pagamento START 1;
CREATE SEQUENCE seq_destino START 1;
CREATE SEQUENCE seq_contrato START 1;
CREATE SEQUENCE seq_acompanhante START 1;
CREATE SEQUENCE seq_historico START 1;

CREATE TABLE hotel (
    id_hotel INT DEFAULT nextval('seq_hotel') PRIMARY KEY,
    nome VARCHAR(60),
    classificacao VARCHAR(1),
    valor_diaria DECIMAL(6,2)
);

CREATE TABLE cep (
    id_cep VARCHAR(9) NOT NULL PRIMARY KEY,
    rua VARCHAR(255) NOT NULL,
    bairro VARCHAR(255) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    pais VARCHAR(30) NOT NULL
);

CREATE TABLE pessoa (
    id_pessoa INT DEFAULT nextval('seq_pessoa') PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    nascimento DATE NOT NULL,
    telefone VARCHAR(16) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    email VARCHAR(50) NOT NULL,
    FOREIGN KEY (cep) REFERENCES cep(id_cep) ON DELETE CASCADE
);

CREATE TABLE cliente (
    id_cliente INT DEFAULT nextval('seq_cliente') PRIMARY KEY,
    id_pessoa INT NOT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE cargo (
    id_cargo INT DEFAULT nextval('seq_cargo') PRIMARY KEY,
    descricao VARCHAR(60) NOT NULL
);

CREATE TABLE funcionario (
    id_func INT DEFAULT nextval('seq_funcionario') PRIMARY KEY,
    id_pessoa INT NOT NULL,
    id_cargo INT NOT NULL,
    salario DECIMAL(9,2) NOT NULL,
    id_gerente INT,
    nro_vendas INT,
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo) ON DELETE CASCADE,
    FOREIGN KEY (id_gerente) REFERENCES funcionario(id_func) ON DELETE SET NULL
);

CREATE TABLE transporte (
    id_transporte INT DEFAULT nextval('seq_transporte') PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL,
    valor DECIMAL(6,2) NOT NULL
);

CREATE TABLE forma_pagamento (
    id_pagamento INT DEFAULT nextval('seq_forma_pagamento') PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE destino (
    id_destino INT DEFAULT nextval('seq_destino') PRIMARY KEY,
    pais VARCHAR(50) NOT NULL,
    estado VARCHAR(55) NOT NULL,
    cidade VARCHAR(55) NOT NULL
);

CREATE TABLE contrato (
    id_contrato INT DEFAULT nextval('seq_contrato') PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_hotel INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_destino INT NOT NULL,
    id_transporte INT NOT NULL,
    id_pagamento INT NOT NULL,
    guia_turistico INT,
    dt_ini DATE NOT NULL,
    dt_fim DATE NOT NULL,
    total DECIMAL(11,1),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_hotel) REFERENCES hotel(id_hotel) ON DELETE CASCADE,
    FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_func) ON DELETE CASCADE,
    FOREIGN KEY (id_destino) REFERENCES destino(id_destino) ON DELETE CASCADE,
    FOREIGN KEY (id_transporte) REFERENCES transporte(id_transporte) ON DELETE CASCADE,
    FOREIGN KEY (id_pagamento) REFERENCES forma_pagamento(id_pagamento) ON DELETE CASCADE,
    FOREIGN KEY (guia_turistico) REFERENCES funcionario(id_func) ON DELETE SET NULL
);

CREATE TABLE acompanhante (
    id_acompanhante INT DEFAULT nextval('seq_acompanhante') PRIMARY KEY,
    id_contrato INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    nascimento DATE NOT NULL,
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato) ON DELETE CASCADE
);

CREATE TABLE historico (
    id_historico INT DEFAULT nextval('seq_historico') PRIMARY KEY,
    id_contrato INT NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION set_gerente() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_gerente IS NULL THEN
        NEW.id_gerente := (SELECT id_func FROM funcionario WHERE id_cargo = (SELECT id_cargo FROM cargo WHERE descricao = 'Gerente') LIMIT 1);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_gerente
BEFORE INSERT ON funcionario
FOR EACH ROW
EXECUTE FUNCTION set_gerente();

CREATE OR REPLACE FUNCTION validar_datas_contrato() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.dt_ini > NEW.dt_fim THEN
        RAISE EXCEPTION 'A data de início deve ser anterior à data de fim.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_datas
BEFORE INSERT OR UPDATE ON contrato
FOR EACH ROW
EXECUTE FUNCTION validar_datas_contrato();



