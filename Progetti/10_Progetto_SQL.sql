/* Creo una tabella temporanea per calcolare l'età dei clienti. */
CREATE TEMPORARY TABLE banca.eta_cliente AS
SELECT 
    id_cliente,
    TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
FROM banca.cliente;

/* Creo una tabella temporanea per calcolare: il numero tatale dei conti per cliente,il numero di conti per tipologia per ogni cliente. */
CREATE TEMPORARY TABLE banca.num_conti AS
SELECT 
    cl.id_cliente,
    COUNT(DISTINCT id_conto) AS num_conti_totali,
    COUNT(CASE WHEN id_tipo_conto = '0' THEN 1 END) AS num_conti_tipo_0,
    COUNT(CASE WHEN id_tipo_conto = '1' THEN 1 END) AS num_conti_tipo_1,
    COUNT(CASE WHEN id_tipo_conto = '2' THEN 1 END) AS num_conti_tipo_2,
	COUNT(CASE WHEN id_tipo_conto = '3' THEN 1 END) AS num_conti_tipo_3
FROM banca.cliente cl
LEFT JOIN banca.conto co 
ON cl.id_cliente = co.id_cliente
GROUP BY 1;

/* Creo una tabella temporanea per studiare le transizioni in entrata e in uscita per ogni cliente. */
CREATE TEMPORARY TABLE banca.ind_transazioni AS
SELECT 
    co.id_cliente,
    COUNT(CASE WHEN tt.segno = '-' THEN 1 END) AS num_transazioni_uscita,
    COUNT(CASE WHEN tt.segno = '+' THEN 1 END) AS num_transazioni_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN t.importo ELSE 0 END) AS importo_totale_uscita,
    SUM(CASE WHEN tt.segno = '+' THEN t.importo ELSE 0 END) AS importo_totale_entrata,
    COUNT(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '0' THEN 1 END) AS num_transazioni_uscita_tipo_0,
    COUNT(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '0' THEN 1 END) AS num_transazioni_entrata_tipo_0,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '0' THEN t.importo ELSE 0 END) AS importo_uscita_tipo_0,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '0' THEN t.importo ELSE 0 END) AS importo_entrata_tipo_0,
    COUNT(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '1' THEN 1 END) AS num_transazioni_uscita_tipo_1,
    COUNT(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '1' THEN 1 END) AS num_transazioni_entrata_tipo_1,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '1' THEN t.importo ELSE 0 END) AS importo_uscita_tipo_1,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '1' THEN t.importo ELSE 0 END) AS importo_entrata_tipo_1,
    COUNT(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '2' THEN 1 END) AS num_transazioni_uscita_tipo_2,
    COUNT(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '2' THEN 1 END) AS num_transazioni_entrata_tipo_2,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '2' THEN t.importo ELSE 0 END) AS importo_uscita_tipo_2,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '2' THEN t.importo ELSE 0 END) AS importo_entrata_tipo_2,
    COUNT(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '3' THEN 1 END) AS num_transazioni_uscita_tipo_3,
    COUNT(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '3' THEN 1 END) AS num_transazioni_entrata_tipo_3,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = '3' THEN t.importo ELSE 0 END) AS importo_uscita_tipo_3,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = '3' THEN t.importo ELSE 0 END) AS importo_entrata_tipo_3
FROM banca.cliente cl
LEFT JOIN banca.conto co 
ON cl.id_cliente = co.id_cliente
LEFT JOIN banca.transazioni t 
ON co.id_conto = t.id_conto
LEFT JOIN banca.tipo_transazione tt 
ON t.id_tipo_trans = tt.id_tipo_transazione
GROUP BY 1;

/* Unisco i valori ottenuti in un'unica tabella. */
SELECT 
    e.id_cliente,
    e.eta,
    COALESCE(nc.num_conti_totali, 0) AS num_conti_totali,
    COALESCE(nc.num_conti_tipo_0, 0) AS num_conti_tipo_0,
    COALESCE(nc.num_conti_tipo_1, 0) AS num_conti_tipo_1,
    COALESCE(nc.num_conti_tipo_2, 0) AS num_conti_tipo_2,
    COALESCE(nc.num_conti_tipo_3, 0) AS num_conti_tipo_3,
    COALESCE(it.num_transazioni_uscita, 0) AS num_transazioni_uscita,
    COALESCE(it.num_transazioni_entrata, 0) AS num_transazioni_entrata,
    COALESCE(it.importo_totale_uscita, 0) AS importo_totale_uscita,
    COALESCE(it.importo_totale_entrata, 0) AS importo_totale_entrata,
    COALESCE(it.num_transazioni_uscita_tipo_0, 0) AS num_transazioni_uscita_tipo_0,
    COALESCE(it.num_transazioni_entrata_tipo_0, 0) AS num_transazioni_entrata_tipo_0,
    COALESCE(it.importo_uscita_tipo_0, 0) AS importo_uscita_tipo_0,
    COALESCE(it.importo_entrata_tipo_0, 0) AS importo_entrata_tipo_0,
    COALESCE(it.num_transazioni_uscita_tipo_1, 0) AS num_transazioni_uscita_tipo_1,
    COALESCE(it.num_transazioni_entrata_tipo_1, 0) AS num_transazioni_entrata_tipo_1,
    COALESCE(it.importo_uscita_tipo_1, 0) AS importo_uscita_tipo_1,
    COALESCE(it.importo_entrata_tipo_1, 0) AS importo_entrata_tipo_1,
    COALESCE(it.num_transazioni_uscita_tipo_2, 0) AS num_transazioni_uscita_tipo_2,
    COALESCE(it.num_transazioni_entrata_tipo_2, 0) AS num_transazioni_entrata_tipo_2,
    COALESCE(it.importo_uscita_tipo_2, 0) AS importo_uscita_tipo_2,
    COALESCE(it.importo_entrata_tipo_2, 0) AS importo_entrata_tipo_2,
    COALESCE(it.num_transazioni_uscita_tipo_3, 0) AS num_transazioni_uscita_tipo_3,
    COALESCE(it.num_transazioni_entrata_tipo_3, 0) AS num_transazioni_entrata_tipo_3,
    COALESCE(it.importo_uscita_tipo_3, 0) AS importo_uscita_tipo_3,
    COALESCE(it.importo_entrata_tipo_3, 0) AS importo_entrata_tipo_3
FROM banca.eta_cliente e
LEFT JOIN banca.num_conti nc 
ON e.id_cliente = nc.id_cliente
LEFT JOIN banca.ind_transazioni it 
ON e.id_cliente = it.id_cliente;