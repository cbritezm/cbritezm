--------------------------------------------------------------------------------
--      Run bind var from sqlplus
--------------------------------------------------------------------------------

var n1 VARCHAR2(32);
var n2 VARCHAR2(32);
var n3 VARCHAR2(32);
var n4 VARCHAR2(32);
var n5 VARCHAR2(32);
var n6 VARCHAR2(32);
var n7 VARCHAR2(32);
var n8 VARCHAR2(32);

exec :n1 :='31306668725';
exec :n2 :='661203027';
exec :n3 :='25959998442';
exec :n4 :='661203027';
exec :n5 :='31306668725';
exec :n6 :='25959998442';
exec :n7 :='661203027';
exec :n8 :='31306668725';

set timing on;
SELECT /*+ INDEX(hcon IDX_HICONTINGUT_HICURS_NT) */ DISTINCT nvl(cdPare.codi, cd.codi) as codi, aca.notajunta,aca.comentari,aca.nota, aca.matricula, cd.valorcategoria, cd.tipificat, aca.estat estatACA, aca.millorajunta, 'F' AS esnotahdq, aca.AVALUACIOCENTRE as avaluacio
FROM matricula mat inner join avaluaciocontingutalumne aca on ( aca.MATRICULA = mat.id and aca.estat <> 'I' and aca.avaluaciocentre = :n1 and mat.id = :n2 )inner join pe_contingutdocent cd on (aca.contingut = cd.id) left outer join pe_contingutdocent cdPare on (cd.pare = cdPare.id ) UNION ALL SELECT NVL(cdpare.codi, cd.codi) AS codi, NULL AS notajunta, hcon.comentaris, hcon.nota, m.ID AS matricula, cd.valorcategoria, cd.tipificat, DECODE(hcon.notadescriptiva, 'C', 'C', 'X', 'E', 'A') AS estataca, nvl(hcon.millorajunta, 'F') as millorajunta, 'T' AS esnotahdq, hcon.AVALUACIO as avaluacio FROM hi_curs hi INNER JOIN hi_contingut hcon ON (hcon.hicurs= hi.ID) INNER JOIN matricula m ON(m.alumnecentre = hi.alumnecentre) INNER JOIN pe_contingutdocent cd ON( case WHEN cd.nom like '%LOEM%' THEN 'Z' END ||cd.codi= case WHEN hcon.nom like '%LOEM%' THEN 'Z' END ||hcon.codi AND cd.etapa = 'ESOLOE' AND hcon.tipus = cd.valorcategoria AND(cd.centre IS NULL OR cd.centre = :n3)) LEFT OUTER JOIN pe_contingutdocent cdpare ON(cd.pare = cdpare.ID) WHERE m.ID =:n4 AND hi.cursescolar = m.cursescolar AND hi.etapa = 'ESO LOE' AND hi.subetapa= 'ESO LOE' AND hcon.avaluacio = 'FC' AND NOT EXISTS( SELECT aca.id FROM matricula mat INNER JOIN avaluaciocontingutalumne aca ON(aca.matricula = mat.ID AND aca.estat <> 'I' AND aca.avaluaciocentre = :n5) INNER JOIN avaluaciocentre avc on (avc.id = aca.avaluaciocentre AND avc.tipusavaluacio = 'FINAL_CURS') INNER JOIN pe_contingutdocent cd2 ON(aca.contingut = cd2.ID) WHERE case WHEN cd2.nom like '%LOEM%' THEN 'Z' END ||cd2.codi = case WHEN hcon.nom like '%LOEM%' THEN 'Z' END ||hcon.codi AND mat.ID = m.id ) UNION ALL SELECT NVL(cdpare.codi, cd.codi) AS codi, NULL AS notajunta, hcon.comentaris, hcon.nota, m.ID AS matricula, cd.valorcategoria, cd.tipificat, DECODE(hcon.notadescriptiva, 'C', 'C', 'X', 'E', 'A') AS estataca, nvl(hcon.millorajunta, 'F') as millorajunta, 'T' AS esnotahdq, hcon.AVALUACIO as avaluacio FROM hi_curs hi INNER JOIN hi_contingut_no_tipificat hcon ON(hcon.hicurs = hi.ID) INNER JOIN matricula m ON (m.alumnecentre = hi.alumnecentre) INNER JOIN pe_contingutdocent cd ON ( case WHEN cd.nom like '%LOEM%' THEN 'Z' END || cd.codi = case WHEN hcon.nom like '%LOEM%' THEN 'Z' END ||hcon.codi AND cd.tipificat = 'F' AND cd.etapa = 'ESOLOE' AND hcon.tipus = cd.valorcategoria AND(cd.centre IS NULL OR cd.centre = :n6) ) LEFT OUTER JOIN pe_contingutdocent cdpare ON (cd.pare = cdpare.ID) WHERE m.ID = :n7 AND hi.cursescolar = m.cursescolar AND hi.etapa = 'ESO LOE' AND hi.subetapa = 'ESO LOE' AND hcon.avaluacio = 'FC' AND NOT EXISTS( SELECT aca.id FROM matricula mat INNER JOIN avaluaciocontingutalumne aca ON ( aca.matricula = mat.ID AND aca.estat <> 'I' AND aca.avaluaciocentre= :n8 ) INNER JOIN avaluaciocentre avc on (avc.id = aca.avaluaciocentre AND avc.tipusavaluacio = 'FINAL_CURS') INNER JOIN pe_contingutdocent cd2 ON (aca.contingut = cd2.ID) WHERE case WHEN cd2.nom like '%LOEM%' THEN 'Z' END ||cd2.codi = case WHEN hcon.nom like '%LOEM%' THEN 'Z' END ||hcon.codi AND mat.ID = m.id ) ORDER BY valorcategoria, codi NULLS LAST;