CREATE TABLE Produtos (
  produto_id INT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Ingredientes (
  ingrediente_id INT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL
);

CREATE TABLE Produtos_Ingredientes (
  produto_id INT,
  ingrediente_id INT,
  quantidade FLOAT,
  PRIMARY KEY (produto_id, ingrediente_id),
  FOREIGN KEY (produto_id) REFERENCES Produtos(produto_id),
  FOREIGN KEY (ingrediente_id) REFERENCES Ingredientes(ingrediente_id)
);

CREATE TABLE Lotes (
  lote_id INT PRIMARY KEY,
  data_producao DATE,
  quantidade INT,
  produto_id INT,
  FOREIGN KEY (produto_id) REFERENCES Produtos(produto_id)
);

CREATE TABLE Estoque (
  ingrediente_id INT PRIMARY KEY,
  quantidade FLOAT,
  FOREIGN KEY (ingrediente_id) REFERENCES Ingredientes(ingrediente_id)
);


-- Inserção dos produtos
INSERT INTO Produtos (produto_id, nome, categoria) VALUES (1, 'Bolo de Chocolate', 'Bolos');

-- Inserção dos ingredientes
INSERT INTO Ingredientes (ingrediente_id, nome) VALUES
  (1, 'Ovos'),
  (2, 'Chocolate em pó'),
  (3, 'Manteiga'),
  (4, 'Farinha de trigo'),
  (5, 'Açúcar'),
  (6, 'Fermento'),
  (7, 'Leite'),
  (8, 'Chocolate');

INSERT INTO Produtos_Ingredientes (produto_id, ingrediente_id, quantidade) VALUES
  (1, 1, 4),  -- 4 ovos
  (1, 2, 4),  -- 4 colheres (sopa) de chocolate em pó
  (1, 3, 2),  -- 2 colheres (sopa) de manteiga
  (1, 4, 3),  -- 3 xícaras (chá) de farinha de trigo
  (1, 5, 2),  -- 2 xícaras (chá) de açúcar
  (1, 6, 2),  -- 2 colheres (sopa) de fermento
  (1, 7, 1),  -- 1 xícara (chá) de leite
  (1, 8, 200); -- 200g de chocolate

INSERT INTO Estoque (ingrediente_id, quantidade) VALUES
  (1, 10),   -- 10 ovos
  (2, 1),    -- 1 colher (sopa) de chocolate em pó
  (3, 1),    -- 1 colher (sopa) de manteiga
  (4, 10),   -- 10 xícaras (chá) de farinha de trigo
  (5, 5),    -- 5 xícaras (chá) de açúcar
  (6, 1),    -- 1 colher (sopa) de fermento
  (7, 10),   -- 10 xícaras (chá) de leite
  (8, 1);    -- 1 kg de chocolate
  
  
  SELECT COUNT(produto_id) AS quantidade_por_categoria, produtos.nome, produtos.categoria
  FROM produtos
  GROUP BY produtos.categoria;
  
  
  SELECT produtos.nome, ingredientes.nome AS nome_ingrediente, produtos_ingredientes.ingrediente_id, produtos_ingredientes.quantidade
  FROM produtos
  INNER JOIN produtos_ingredientes ON produtos_ingredientes.produto_id = produtos.produto_id
  INNER JOIN ingredientes ON ingredientes.ingrediente_id = produtos_ingredientes.ingrediente_id
  GROUP BY produtos_ingredientes.ingrediente_id;
  
   SELECT lotes.quantidade AS quantidade_produzida
   FROM produtos
   LEFT JOIN lotes ON lotes.produto_id = produtos.produto_id
   WHERE lotes.data_producao BETWEEN '2023-05-01' AND '2023-05-31'
   GROUP BY produtos.nome;
  
	SELECT i.nome AS nome_ingrediente, SUM(pi.quantidade * 2) AS quantidade_necessaria
	FROM Produtos p
	INNER JOIN Produtos_Ingredientes pi ON pi.produto_id = p.produto_id
	INNER JOIN Ingredientes i ON i.ingrediente_id = pi.ingrediente_id
	GROUP BY pi.ingrediente_id;
	
	SELECT i.nome AS nome_ingrediente
	FROM Ingredientes i
	LEFT JOIN Produtos_Ingredientes pi ON i.ingrediente_id = pi.ingrediente_id
	WHERE pi.ingrediente_id IS NULL;
	
	
CREATE TRIGGER atualizar_estoque
AFTER INSERT ON Lotes
FOR EACH ROW
BEGIN
    -- Atualizar as quantidades de estoque dos ingredientes utilizados no lote
    UPDATE Estoque
    SET quantidade = quantidade - (
        SELECT quantidade
        FROM Produtos_Ingredientes
        WHERE produto_id = NEW.produto_id
          AND ingrediente_id = Estoque.ingrediente_id
    )
    WHERE Estoque.ingrediente_id IN (
        SELECT ingrediente_id
        FROM Produtos_Ingredientes
        WHERE produto_id = NEW.produto_id
    );
END;





START TRANSACTION;

-- Obter a quantidade atual de fermento utilizado em cada produto
SELECT produto_id, ingrediente_id, quantidade
INTO @prod_fermento
FROM Produtos_Ingredientes
WHERE ingrediente_id = 6; -- ID do fermento

-- Calcular a nova quantidade de fermento reduzida em 10%
UPDATE Produtos_Ingredientes
SET quantidade = quantidade * 0.9
WHERE ingrediente_id = 6; -- ID do fermento

-- Verificar se houve algum erro durante a atualização
IF ROW_COUNT() > 0 THEN
    -- Caso não haja erros, confirmar a transação
    COMMIT;
ELSE
    -- Caso haja erros, desfazer a transação
    ROLLBACK;
END IF;

-- Selecionar as receitas atualizadas
SELECT p.nome AS nome_produto, i.nome AS nome_ingrediente, pi.quantidade
FROM Produtos p
INNER JOIN Produtos_Ingredientes pi ON pi.produto_id = p.produto_id
INNER JOIN Ingredientes i ON i.ingrediente_id = pi.ingrediente_id
WHERE pi.ingrediente_id = 6; -- ID do fermento



START TRANSACTION; -- Exclua todos os registros de produção do  último mês; 

-- Obter a data atual menos um mês
SET @data_atual = CURDATE();
SET @data_mes_passado = DATE_SUB(@data_atual, INTERVAL 1 MONTH);

-- Excluir os registros de produção do último mês
DELETE FROM Producao
WHERE data_producao >= @data_mes_passado AND data_producao < @data_atual;

-- Verificar se houve algum erro durante a exclusão
IF ROW_COUNT() > 0 THEN
    -- Caso não haja erros, confirmar a transação
    COMMIT;
ELSE
    -- Caso haja erros, desfazer a transação
    ROLLBACK;
END IF;




  


