EXPLAIN SELECT p.valor_pago FROM tb_pagamentos p 
JOIN tb_mensalidades m ON p.fk_mensalidade = m.pk_mensalidade 
WHERE p.data_pagamento = CURDATE();

CREATE INDEX idx_pagamento_data ON tb_pagamentos(data_pagamento);

CREATE INDEX idx_mensalidade_aluno ON tb_mensalidades(fk_aluno);

EXPLAIN SELECT p.valor_pago FROM tb_pagamentos p 
JOIN tb_mensalidades m ON p.fk_mensalidade = m.pk_mensalidade 
WHERE p.data_pagamento = CURDATE();